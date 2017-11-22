pipeline {
    agent any
    
    stages {
        stage ('Copy Chef configuration files to directory') {
            steps {
                sh 'cp -R /chef .chef'
            }
        }
        stage ('Install Berks files') {
            steps {
                sh 'berks install'
            }
        }

        stage ('Update Berks files') {
            steps {
                sh 'berks update'
            }
        }

        stage ('Upload cookbook to chef server') {
            steps {
                sh 'berks upload'
            }
        }
    }
}