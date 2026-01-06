FROM mcr.microsoft.com/playwright:v1.57.0-jammy
RUN npm install netlify-cli node-jq
#RUN npm install netlify-cli@20.1.1 node-jq