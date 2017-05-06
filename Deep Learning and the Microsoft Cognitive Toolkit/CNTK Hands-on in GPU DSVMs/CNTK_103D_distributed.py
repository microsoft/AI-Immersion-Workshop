from __future__ import print_function # Use a function definition from future version (say 3.x from 2.7 interpreter)
import numpy as np
import os
import sys
import time

import cntk as C
from cntk.train.training_session import *

# comment out the following line to get auto device selection for multi-GPU training
C.device.try_set_default_device(C.device.gpu(0))

# Ensure we always get the same amount of randomness
np.random.seed(0)

# Define the data dimensions
input_dim_model = (1, 28, 28)    # images are 28 x 28 with 1 channel of color (gray)
input_dim = 28*28                # used by readers to treat input data as a vector
num_output_classes = 10

# Read a CTF formatted text (as mentioned above) using the CTF deserializer from a file
def create_reader(path, is_training, input_dim, num_label_classes, total_number_of_samples):

    ctf = C.io.CTFDeserializer(path, C.io.StreamDefs(
          labels=C.io.StreamDef(field='labels', shape=num_label_classes, is_sparse=False),
          features=C.io.StreamDef(field='features', shape=input_dim, is_sparse=False)))

    return C.io.MinibatchSource(ctf,
        randomize = is_training,
        max_samples=total_number_of_samples,
        multithreaded_deserializer = True)

# Ensure the training and test data is available for this tutorial.
# We search in two locations in the toolkit for the cached MNIST data set.

data_found=False # A flag to indicate if train/test data found in local cache
for data_dir in [os.path.join("..", "Examples", "Image", "DataSets", "MNIST"),
                 os.path.join("data", "MNIST")]:

    train_file=os.path.join(data_dir, "Train-28x28_cntk_text.txt")
    test_file=os.path.join(data_dir, "Test-28x28_cntk_text.txt")

    if os.path.isfile(train_file) and os.path.isfile(test_file):
        data_found=True
        break

if not data_found:
    raise ValueError("Please generate the data by completing CNTK 103 Part A")

print("Data directory is {0}".format(data_dir))

# In this CNN tutorial, we first define two containers. One for the input MNIST image and the second one being the labels corresponding to the 10 digits. When reading the data, the reader automatically maps the 784 pixels per image to a shape defined by `input_dim_model` tuple (in this example it is set to (1, 28, 28)).

x = C.input(input_dim_model)
y = C.input(num_output_classes)

# function to build model

def create_model(features):
    with C.layers.default_options(init=C.glorot_uniform(), activation=C.relu):
            h = features
            h = C.layers.Convolution2D(filter_shape=(5,5),
                                       num_filters=8,
                                       strides=(2,2),
                                       pad=True, name='first_conv')(h)
            h = C.layers.Convolution2D(filter_shape=(5,5),
                                       num_filters=16,
                                       strides=(2,2),
                                       pad=True, name='second_conv')(h)
            r = C.layers.Dense(num_output_classes, activation=None, name='classify')(h)
            return r

# Create the model
z = create_model(x)

# Print the output shapes / parameters of different components
print("Output Shape of the first convolution layer:", z.first_conv.shape)
print("Bias value of the last dense layer:", z.classify.b.value)

# Number of parameters in the network
C.logging.log_number_of_parameters(z)

def create_criterion_function(model, labels):
    loss = C.cross_entropy_with_softmax(model, labels)
    errs = C.classification_error(model, labels)
    return loss, errs # (model, labels) -> (loss, error metric)

def train_test(train_reader, test_reader, model_func, epoch_size):

    # Instantiate the model function; x is the input (feature) variable
    # We will scale the input image pixels within 0-1 range by dividing all input value by 255.
    model = model_func(x/255)

    # Instantiate the loss and error function
    loss, label_error = create_criterion_function(model, y)

    # Instantiate the trainer object to drive the model training
    learning_rate = 0.2
    lr_schedule = C.learning_rate_schedule(learning_rate, C.UnitType.minibatch)
    learner = C.sgd(z.parameters, lr_schedule)

    # use a distributed learner for multi-GPU training
    # either a data_parallel learner
    distributed_learner = C.distributed.data_parallel_distributed_learner(learner = learner, num_quantization_bits = 1)
    # or a block momemtum learner
    # distributed_learner = C.train.distributed.block_momentum_distributed_learner(learner, block_size=block_size)

    distributed_sync_report_freq = None
    #if block_size is not None:
    #    distributed_sync_report_freq = 1

    progress_writers = [C.logging.ProgressPrinter(
        freq=None,
        tag='Training',
        log_to_file=None,
        rank=C.train.distributed.Communicator.rank(),
        gen_heartbeat=False,
        num_epochs=5,
        distributed_freq=distributed_sync_report_freq)]

    trainer = C.Trainer(z, (loss, label_error), [distributed_learner], progress_writers)

    # Initialize the parameters for the trainer
    minibatch_size = 20000

    # Map the data streams to the input and labels.
    input_map={
        y  : train_reader.streams.labels,
        x  : train_reader.streams.features
    }

    # Uncomment below for more detailed logging
    training_progress_output_freq = 500

    # Start a timer
    start = time.time()

    training_session(
        trainer=trainer, mb_source = train_reader,
        model_inputs_to_streams = input_map,
        mb_size = minibatch_size,
        progress_frequency=epoch_size,
        test_config = TestConfig(source = test_reader, mb_size=minibatch_size)
    ).train()

    # Print training time
    print("Training took {:.1f} sec".format(time.time() - start))

def do_train_test():
    global z
    z = create_model(x)

    epoch_size = 60000
    # low for demo purposes
    num_epochs = 5
    total_number_of_samples = epoch_size * num_epochs

    reader_train = create_reader(train_file, True, input_dim, num_output_classes, total_number_of_samples)
    reader_test = create_reader(test_file, False, input_dim, num_output_classes, C.io.FULL_DATA_SWEEP)
    train_test(reader_train, reader_test, z, epoch_size)

try:
    do_train_test()
finally:
    C.train.distributed.Communicator.finalize()
