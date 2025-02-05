@Library('k8s-shared-lib') _
pipeline {
    agent none
    environment {
        IMAGE_NAME = "owasp-dependency"
        IMAGE_TAG = "latest"
        DOCKER_HUB_REPO = "naivedh/owasp-dependency"
        DOCKER_CREDENTIALS = "docker_hub_up"
        REPORT_FILE = "trivy-report.json"
    }

    stages {
        stage('Build Docker Image') {
            agent {
                kubernetes {
                    yaml docker('docker-build', 'docker:latest')
                    showRawYaml false
                }
            }
            steps {
                container('docker-build') {
                    script {
                        withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                        sh """
                        docker build --build-arg NVD_API_KEY=$NVD_API_KEY -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        """

                        // Verify image exists
                        sh "docker images | grep '${IMAGE_NAME}' || { echo 'Docker image not found!'; exit 1; }"

                        // Save and compress the Docker image
                        echo "Saving and compressing Docker image..."
                        sh """
                            docker save ${IMAGE_NAME}:${IMAGE_TAG} | gzip > "${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
                        """

                        // Verify the compressed file
                        sh """
                            ls -lh "${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
                            gunzip -t "${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz" || { echo 'Compressed file is corrupt!'; exit 1; }
                        """

                        // Stash the Docker image
                        stash name: 'docker-image', includes: "${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
                        }
                    }
                }
            }
        }

        stage('Trivy Scan') {
            agent {
                kubernetes {
                    yaml trivy()
                    showRawYaml false
                }
            }
            steps {
                container('docker') {
                    script {
                        // Unstash the Docker image
                        unstash 'docker-image'

                        // Decompress and load the Docker image
                        sh "gunzip ${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
                        sh "docker load -i ${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
                    }
                }
                container('trivy') {
                    script {
                        // Scan the Docker image with Trivy || --exit-code 1 --severity HIGH,CRITICAL
                        sh "mkdir -p /root/.cache/trivy/db"
                        sh "trivy image --download-db-only --timeout 60m --debug"
                        echo "Scanning image with Trivy..."
                        sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG} --timeout 30m --format json --output ${REPORT_FILE} --debug"
                        archiveArtifacts artifacts: "${REPORT_FILE}", fingerprint: true
                    }
                }
            }
        }
        stage('Push Docker Image') {
            agent {
                kubernetes {
                    yaml docker('docker-push', 'docker:latest')
                    showRawYaml false
                }
            }
            steps {
                container('docker-push') {
                    script {
                        // Unstash the Docker image
                        unstash 'docker-image'

                        // Decompress and load the Docker image
                        sh "gunzip ${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
                        sh "docker load -i ${WORKSPACE}/${IMAGE_NAME}-${IMAGE_TAG}.tar"

                        // Push the Docker image
                        withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                            echo "Logging into Docker Hub..."
                            sh '''
                                echo $PASSWORD | docker login -u $USERNAME --password-stdin
                                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_HUB_REPO}:${IMAGE_TAG}
                                docker push ${DOCKER_HUB_REPO}:${IMAGE_TAG}
                            '''
                        }
                    }
                }
            }
        }
    }
}