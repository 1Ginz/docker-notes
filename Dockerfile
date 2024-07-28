#From: chỉ định image để bắt đầu
#sau đó ta sẽ viết tiếp để custom để có được môi trường mong muốn
FROM node:14-alpine3.16

# LABEL: meta data sẽ gắn vào image để có thể biết rõ hơn
LABEL authors="Hung Le"

#ARG: biến dùng cho quá trình built image
ARG author=Hung

# WORKDIR: Đặt thư mục làm việc cho các instruction phía dưới
WORKDIR /app

# COPY: Sao chép files từ host vào image
COPY ./imgs /data/

# ADD: Tương tự COPY
#nhưng có thêm tính năng như giải nén và down file theo url
ADD https://example.com/archive.zip /usr/src/things/

# ENV: Đặt biến môi trường bên trong container
ENV DBNAME=TESTDOCKER

#EXPOSE: meta data khai báo port mà container sẽ lắng nghe
EXPOSE 8080

# RUN: Thực thi các lệnh trong quá trình build
RUN apt-get update

# CMD: Đặt lệnh mặc định khi container chạy
CMD [ "npm", "start"]