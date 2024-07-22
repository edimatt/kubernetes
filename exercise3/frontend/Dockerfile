FROM node:22-alpine3.19
RUN adduser -D nuser
USER nuser
WORKDIR /home/nuser
ENV PATH=/home/fapi/.local/bin:$PATH

# Create package.json with npm init and install dependencies
RUN npm init -y \
    && npm install express axios

COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
