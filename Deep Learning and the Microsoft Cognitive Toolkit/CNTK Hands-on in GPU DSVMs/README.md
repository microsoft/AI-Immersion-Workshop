= CNTK and MNIST on a single GPU

The CNTK_103D_MNIST_ConvolutionalNeuralNetwork notebook is a good example of a convolutional network applied to the MNIST dataset. Here we'll show how it uses the GPU.

nvidia-smi is a tool to show the processes running on a GPU, its utilization, and other useful information. It is available at the command line. To get a terminal through JupyterHub, go to the JupyterHub overview page, click New in the top-right corner, and select Terminal. You will get a new window that is running a bash terminal. From here, run nvidia-smi. You can also run nvidia-smi on a loop with the -lms option. Start nvidia-smi in a loop, then run the 103D notebook. Watch how the GPU memory is allocated, then the GPU utilization increases as the notebook begins training.

== TensorBoard

TensorBoard is a tool from Google to visualize deep neural networks and training progress in your browser. CNTK supports writing output in the TensorBoard format. Create a new TensorBoardProgressWriter and pass it to your learner:

        tensorboard_writer = TensorBoardProgressWriter(freq=10, log_dir='log', model=my_model)
        trainer = cntk.Trainer(--, --, --, tensorboard_writer)

To view the output, log in to the remote desktop on the DSVM via X2Go. You can then start TensorBoard at a terminal:

        source /anaconda/bin/activate py35
        tensorboard --logdir=log

Start a browser and navigate to http://localhost:6006. View the training progress under Scalars and the network under Graphs.

= Docker

Docker is a way to ship an application as a lightweight container. It provides a way to package up an application and its dependencies, then have it run on any machine. Docker does this by providing images which you can run. For example, CNTK has an image. When you run a container, it looks like a separate VM, with its own file system and set of files, but it's sharing the OS kernel with the underlying host. So it's lighter weight than a VM, at the expense of often offering less isolation. It's often used to simplify deployment (because it offers a reproducible environment). On the DSVM, docker makes it easy to try new frameworks without compiling, configuring, etc.

nvidia-docker is a thin wrapper around docker to enable GPU access inside a running container. You need the driver in the container to match the one in the host, and you need the GPU device(s) to be exposed in the container. Nvidia-docker handles these for you.
  
An example is packaged on the Workshop DSVMs for you. To run it, at a Terminal:

nvidia-docker run -it -v ~/CHAINER:/host chainer/chainer
cd /host
python MNIST_chainer.py

To run it on another DSVM, clone the repo, then in the CNTK Hands-on in GPU DSVMs folder:

python download_MNIST_chainer.py
nvidia-docker run -it -v $PWD:/host chainer/chainer
cd /host
python MNIST_chainer.py

= DIGITS

To configure X2GO:
    - Create a new session with Session -> New Session.
    - enter a Session Name, Host, and Login.
    - Set the Session type to XFCE.
    - Under Input/Output, Uncheck Set display DPI. Make sure the resolution, under Display, is set to Custom: 800 width, 600 height.
    - Under Media, uncheck Enable sound support and Client side printing support.

Click OK. Your session will appear as a new session on the right-hand side. Click it, then enter your password to connect.

Once you're connected, start the DIGITS server if it is not running. At a terminal:

sudo systemctl start digits

It will take about a minute for the server to start.

The DIGITS server is running at http://localhost:5000. Open a browser and navigate there.

There are some great tutorials on DIGITS, including one on [MNIST](https://github.com/NVIDIA/DIGITS/blob/master/docs/GettingStarted.md). We've included a script to download the dataset, download_MNIST_DIGITS.sh. It will put the data in ~/mnist.
