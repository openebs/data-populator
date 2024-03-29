#!/bin/bash

# Copyright 2022 The OpenEBS Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

## find or download controller-gen
CONTROLLER_GEN=$(which controller-gen)

if [ "$CONTROLLER_GEN" = "" ]
then
  echo "ERROR: failed to get controller-gen, Please run make bootstrap to install it";
  exit 1;
fi

$CONTROLLER_GEN crd:trivialVersions=false,preserveUnknownFields=false paths=./apis/openebs.io/... output:crd:artifacts:config=deploy/crds

## create the the crd yamls
{
echo "

###############################################
###########                        ############
###########   DataPopulator CRD    ############
###########                        ############
###############################################

# DataPopulator CRD is autogenerated via \`make manifests\` command.
# Do the modification in the code and run the \`make manifests\` command
# to generate the CRD definition"

cat deploy/crds/openebs.io_datapopulators.yaml
} > deploy/crds/datapopulator-crd.yaml
rm deploy/crds/openebs.io_datapopulators.yaml

{
echo "

###############################################
###########                        ############
###########   RsyncPopulator CRD   ############
###########                        ############
###############################################

# RsyncPopulator CRD is autogenerated via \`make manifests\` command.
# Do the modification in the code and run the \`make manifests\` command
# to generate the CRD definition"

cat deploy/crds/openebs.io_rsyncpopulators.yaml
} > deploy/crds/rsyncpopulator-crd.yaml
rm deploy/crds/openebs.io_rsyncpopulators.yaml

## create the operator file using all the yamls
{
echo "# This manifest is autogenerated via \`make manifests\` command
# Do the modification to the data-populator.yaml or rsync-populator in
# directory deploy/yamls/ and then run \`make manifests\` command

# This manifest deploys the data populator components,
# with associated CRs & RBAC rules.
"

# Add data populator v1alpha1 CRDs to the Operator yaml
cat deploy/crds/datapopulator-crd.yaml

# Add rsync populator v1alpha1 CRDs to the Operator yaml
cat deploy/crds/rsyncpopulator-crd.yaml

# Add the data populator deployment to the Operator yaml
cat deploy/yamls/data-populator.yaml

# Add the rsync populator deployment to the Operator yaml
cat deploy/yamls/rsync-populator.yaml
} > deploy/data-populator-operator.yaml

# To use your own boilerplate text use:
#   --go-header-file ${SCRIPT_ROOT}/hack/custom-boilerplate.go.txt
