FROM node:latest
# ENV ENV dev
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install -g typescript
RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 3000
RUN tsc
CMD npm start