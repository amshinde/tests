# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Path of Clear Containers Runtime
CC_RUNTIME ?= cc-runtime

# The time limit in seconds for each test
TIMEOUT ?= 5

CRIO_REPO_PATH="${GOPATH}/src/github.com/kubernetes-incubator/cri-o"
crio:
	bash .ci/install_bats.sh
	ln -sf $(PWD)/integration/cri-o/crio.bats ${CRIO_REPO_PATH}/test
	cd ${CRIO_REPO_PATH} && \
	make localintegration RUNTIME=${CC_RUNTIME} TESTFLAGS="crio.bats"

ginkgo:
	ln -sf . vendor/src
	GOPATH=$(PWD)/vendor go build ./vendor/github.com/onsi/ginkgo/ginkgo
	unlink vendor/src

functional: ginkgo
	./ginkgo functional/ -- -runtime ${CC_RUNTIME} -timeout ${TIMEOUT}

check:	functional crio

all: functional checkcommits

checkcommits:
	cd cmd/checkcommits && make

clean:
	cd cmd/checkcommits && make clean

.PHONY: functional check ginkgo crio
