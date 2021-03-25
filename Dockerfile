FROM ubuntu
COPY . .
RUN apt update && apt install redis-server -y
RUN /etc/init.d/redis-server start
CMD "./start.sh"
