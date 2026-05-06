FROM node:20-slim

RUN apt-get update && apt-get install -y procps --no-install-recommends && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN npm install -g @angular/cli@17 --legacy-peer-deps

COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY . .

EXPOSE 8100

CMD ["ng", "serve", "--host", "0.0.0.0", "--port", "8100", "--poll", "2000"]
