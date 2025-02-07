@Library('k8s-shared-lib') _
pipeline {
    agent {
        kubernetes {
            yaml trivy()
            showRawYaml false
        }
    }
    environment {
        IMAGE_NAME = "owasp-dependency"
        IMAGE_TAG = "latest"
        DOCKER_HUB_REPO = "naivedh/owasp-dependency"
        DOCKER_CREDENTIALS = "docker_hub_up"
        REPORT_FILE = "trivy-report.json"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                        sh """
                        docker build --build-arg NVD_API_KEY=$NVD_API_KEY -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        """
                        }
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
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
            steps {
                container('docker') {
                    script {
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