
@Library('addons') _

pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
        disableConcurrentBuilds()
        ansiColor('xterm')
        parallelsAlwaysFailFast()
    }
    environment {
        SERVICE_NAME = "crushftp"
        ORGANIZATION_NAME = "deetechpro"
        DOCKERHUB_USERNAME = "oluwaseyi12"
        REPOSITORY_TAG = "${DOCKERHUB_USERNAME}/${ORGANIZATION_NAME}-${SERVICE_NAME}:${BUILD_ID}"
        SCANNER_HOME= tool 'sonar-scanner
    }

    stages {
        stage('QA') {
            when {
                branch 'qa'
                beforeAgent true
            }
            stages {
                stage('Pre work') {
                    steps {
                        script {
                            setGit()
                            setEKS()
                            setHelm()
                        }
                    }
                }
                stage('Validate Helm') {
                    steps {
                        sh "helm lint ./${NAME} --values ./qa.yaml"
                    }
                }
                stage('Docker Push') {
                    steps {
                        script {
                            dockerUp()
                        }
                    }
                }
                stage('Deploy') {
                    steps {
                        withCredentials([string(credentialsId: 'CRUSH_ADMIN_PASSWORD', variable: 'CRUSH_ADMIN_PASSWORD')
                        ]) {
                            sh "aws eks --region eu-west-1 update-kubeconfig --name switch-arca-qa-cluster"
                            sh "kubectl apply -f ./namespace.yaml"
                            sh "helm upgrade \
                            --namespace core-services \
                            --values ./qa.yaml \
                            --set adminUser.passwordvalue=${CRUSH_ADMIN_PASSWORD} \
                            --set image.repository=${env.REGISTRY_HOST}/${NAME} \
                            --set image.tag=latest \
                            --set imageSecretName=docker-registry \
                            --set 'tolerations[0].effect=NoSchedule' \
                            --set 'tolerations[0].key=crushftp' \
                            --set 'tolerations[0].operator=Exists' \
                            --set nodeSelector.purpose=crushftp \
                            --atomic \
                            --install \
                            --wait ${NAME} ./${NAME}"
                        }
                    }
                }
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
        stage('Production') {
            when {
                branch 'master'
                beforeAgent true
            }
            stages {
                stage('Pre work') {
                    steps {
                        script {
                            setGit()
                            setEKS()
                            setHelm()
                        }
                    }
                }
                stage('Validate Helm') {
                    steps {
                        sh "helm lint ./${NAME} --values ./prod.yaml"
                    }
                }
                stage('Docker Push') {
                    steps {
                        script {
                            dockerUp()
                        }
                    }
                }
                stage('Deploy') {
                    steps {
                        withCredentials([string(credentialsId: 'CRUSH_ADMIN_PASSWORD', variable: 'CRUSH_ADMIN_PASSWORD')
                        ]) {
                            withAWS(region: 'eu-west-1', role: 'arn:aws:iam::164135465533:role/Jenkins') {
                                sh "aws eks --region eu-west-1 update-kubeconfig --name switch-arca-prod-cluster"
                                sh "kubectl apply -f ./namespace.yaml"
                                sh "helm upgrade \
                                --namespace core-services \
                                --values ./prod.yaml \
                                --set adminUser.passwordvalue=${CRUSH_ADMIN_PASSWORD} \
                                --set image.repository=${env.REGISTRY_HOST}/${NAME} \
                                --set imageSecretName=docker-registry \
                                --set 'tolerations[0].effect=NoSchedule' \
                                --set 'tolerations[0].key=crushftp' \
                                --set 'tolerations[0].operator=Exists' \
                                --set nodeSelector.purpose=crushftp \
                                --atomic \
                                --install \
                                --wait ${NAME} ./${NAME}"
                            }    
                        }
                    }
                }
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
    }
}
