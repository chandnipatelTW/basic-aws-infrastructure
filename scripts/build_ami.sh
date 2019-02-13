usage() {
    echo "Use Packer to build an Amazon Machine Image"
    echo "./build_ami.sh image"
    echo "For example:"
    echo "./run_terraform.sh training_kafka"
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "No AWS region configured, consider setting the AWS_DEFAULT_REGION environment variable."
    exit 1
fi

IMAGE_DIR=${PACKER_IMAGE_DIR:-images}
TEMPLATE_FILE=template.json
IMAGE_NAME=$1

pushd $IMAGE_DIR/$IMAGE_NAME > /dev/null

packer build $TEMPLATE_FILE

popd > /dev/null


