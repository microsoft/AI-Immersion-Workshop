#!/usr/bin/env python
import cPickle as pickle
import os

import chainer

train, test = chainer.datasets.get_mnist()
with open('/etc/skel/CHAINER/data.pkl', 'wb') as output:
    pickle.dump(train, output, pickle.HIGHEST_PROTOCOL)
