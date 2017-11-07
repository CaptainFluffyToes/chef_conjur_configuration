pipeline {
    agent any
    
    stages {
        stage ('Install Berks files') {
            sh 'berks install'
        }

        stage ('Update Berks files') {
            sh 'berks update'
        }

        stage ('Upload cookbook to chef server') {
            sh 'berks upload'
        }
    }
}