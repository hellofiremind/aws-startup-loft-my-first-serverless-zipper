FROM node:16-alpine

COPY src/ecs .
COPY infrastructure/terraform-state.json .

RUN npm ci

CMD [ "node", "./ecs.js" ]
