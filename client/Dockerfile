FROM node:latest as generate_dist
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install -g typescript
RUN npm install -g @angular/cli
RUN npm install --silent
COPY . .
RUN npm run build

FROM nginx:1.13.12-alpine
RUN rm /etc/nginx/conf.d/default.conf
# dist/myclient is set in angular.json
COPY --from=generate_dist /usr/src/app/dist/myclient /usr/share/nginx/html