FROM mcr.microsoft.com/playwright:v1.57.0-jammy
RUN npm install -g netlify-cli@20.1.1 serve
RUN apt update && apt install jq -y