pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '6297fc3e-f63d-4fdf-a405-086c5184f333'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "small Change"
                    node --version
                    npm --version
                    npm ci
                    npm run build
                '''
            }
        }
        stage('Tests') {
            parallel {
                stage('Unit tests') {
        agent {
            docker {
                image 'node:18-alpine'
                reuseNode true
            }
      }
        steps {
            sh '''
                export JEST_JUNIT_OUTPUT_DIR=jest-results
                export JEST_JUNIT_OUTPUT_NAME=junit.xml

                mkdir -p jest-results
                npm test -- --watch=false
                ls -la jest-results
            '''
        }
        post {
        always {
            junit 'jest-results/junit.xml'
            }
        }
    }
        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.57.0-jammy'
                        reuseNode true
                        }
                }
                steps {
                    sh '''
                        npm install serve
                        node_modules/.bin/serve -s build &
                        sleep 10
                        npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Playwright Local Report'
                            ])
                        }
                    }
                }
            }
        }
        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            steps {
                sh '''
                    npm install netlify-cli node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                    CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)
                    npx playwright test  --reporter=html
                '''
            }
            post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Stage E2E Report'
                            ])
                        }
                    }
        }
        stage('Approval') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                 input 'Ready to Deploy to Prod?'
                }
            }
        }
        stage('Deploy to prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            environment {
                CI_ENVIRONMENT_URL = 'https://legendary-pony-5bf8b7-1.netlify.app'
            }
            steps {
                sh '''
                    node --version
                    npm install netlify-cli@20.1.1
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    npx playwright test  --reporter=html
                '''
            }
            post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'playwright-report',
                                reportFiles: 'index.html',
                                reportName: 'Prod E2E Report'
                            ])
                        }
                }
        }
    }
}
