
FROM node:20-slim 

RUN USER=root apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install git

# Create app directory
WORKDIR /usr/src/app
RUN ls -la
RUN git clone -b do_server https://github.com/usmanshahid86/twilight-self-backend.git
WORKDIR /usr/src/app/twilight-self-backend
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Install production dependencies. If you need dev dependencies, remove --omit=dev
RUN npm ci --omit=dev && npm cache clean --force;

COPY .env.twilight-self-backend .env

# The backend listens on port 3001 by default
EXPOSE 3001

# Define environment defaults (can be overridden at run-time)
# ENV NODE_ENV=production \
#     PORT=3001

# Start the server
CMD ["npm", "start"]