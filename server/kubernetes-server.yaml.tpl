apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-deployment
  labels:
    App: label-nodejs
spec:
  selector:
    matchLabels:
      App: label-nodejs
  replicas: 1
  template:
    metadata:
      labels:
        App: label-nodejs
    spec:
      containers:
        - name: nodejs-container
          image: gcr.io/GOOGLE_CLOUD_PROJECT/mynodejs:COMMIT_SHA
          imagePullPolicy: Always
          env:
            - name: MYSQL_HOST
              value: "10.220.0.3"
            - name: MYSQL_DATABASE
              value: my-database
            - name: MYSQL_USER
              value: rajesh
            - name: MYSQL_PASSWORD
              value: master12
            - name: PORT
              value: "3000"
          ports:
            - containerPort: 3000
