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
        REPORT_FILE = "trivy-report.sarif"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                        sh 'export DOCKER_BUILDKIT=1'
                        sh 'echo -n "$NVD_API_KEY" > /tmp/NVD_API_KEY'
                        sh 'docker build --secret id=NVD_API_KEY,src=/tmp/NVD_API_KEY -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                        sh 'rm -f /tmp/NVD_API_KEY'
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
                        sh "trivy image --download-db-only --timeout 15m --debug"
                        echo "Scanning image with Trivy..."
                        sh "trivy image ${IMAGE_NAME}:${IMAGE_TAG} --timeout 30m --format sarif --output ${REPORT_FILE} --debug"
                        archiveArtifacts artifacts: "${REPORT_FILE}", fingerprint: true
                        recordIssues(
                                enabledForFailure: true,
                                tool: sarif(pattern: "${env.REPORT_FILE}", id: "TRIVY-SARIF", name: "Trivy-Report" ))
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
