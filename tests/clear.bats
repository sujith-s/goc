#!/usr/bin/env bats
# Copyright 2020 Qiniu Cloud (七牛云)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load util.sh

setup_file() {
    # run centered server
    goc server 3>&- &
    GOC_PID=$!
    sleep 2
    goc init

    # run covered goc
    gocc server --port=:60001 --debug 3>&- &
    GOCC_PID=$!
    sleep 1

    WORKDIR=$PWD
    cd samples/run_for_several_seconds
    gocc build --center=http://127.0.0.1:60001
    ./simple-project 3>&- &
    SAMPLE_PID=$!
    sleep 2

    info "goc server started"
}

teardown_file() {
    kill -9 $GOC_PID
    kill -9 $GOCC_PID
    kill -9 $SAMPLE_PID
}

@test "test basic goc clear command" {
    wait_profile_backend "clear1"

    run gocc clear --debug --debugcisyncfile ci-sync.bak;
    info clear1 output: $output
    [ "$status" -eq 0 ]
    [[ "$output" == *"coverage counter clear call successfully"* ]]
}

@test "test clear another center" {
    wait_profile_backend "clear2"

    run gocc clear --center=http://127.0.0.1:60001 --debug --debugcisyncfile ci-sync.bak;
    info clear2 output: $output
    [ "$status" -eq 0 ]
    [[ "$output" == *"coverage counter clear call successfully"* ]]
}