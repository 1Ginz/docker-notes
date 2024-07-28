# Docker note

## Mục lục
- [I. Why need docker?](#i-why-need-docker)
- [II. What is docker?](#ii-what-is-docker)
- [III. Docker architecture](#iii-docker-architecture)
- [IV. Deep Dive](#iv-deep-dive)
  - [1. Docker File](#1-docker-file)
  - [2. Docker image](#2-docker-image)
  - [3. Docker Container](#3-docker-container)
  - [4. Docker Data](#4-docker-data)
  - [5. Docker Network](#5-docker-network)

## I. Why need docker?

Tưởng tưởng chúng ta sắp đi du lịch, trừ cần mang theo bản thân mình, thì ta cũng cần mang theo quần áo, khăn tắm, bàn chải đánh răng,... Vậy để mang nhiều đồ như vậy chúng ta cần 1 cái vali có thể gói lại hết đồ dùng của chúng ta

Vậy trong phát triển phần mềm, chúng ta làm việc giữa các môi trường dev, test, production, ...  ta có thể gặp vài vấn đề sau:
+ việc quản lí các dependency, server dev có thể cài java 21, nhưng production cài java 8 thôi và **bum, running lỗi**
+ hay một ngày đẹp trời sever production sập không thể bật lại, ta cần 1 sever mới phải cài lại đủ thứ để running được

Vậy ta cần 1 cái vali có thể gói hết tất cả những gì ta cần để ứng dụng chạy tốt và có thể mang nó đi khắp nơi, cái vali đó là **DOCKER**

## II. What is docker?

**Docker là containerization technology cho phép ta developing, shipping, running application 1 cách riêng biệt mà chúng ta không cần quan tâm đến hạ tầng.**

Docker cung cấp khả năng đóng gói và chạy ứng dụng trong một môi trường riêng được gọi là container.  
Các container chứa mọi thứ cần thiết để running application, do đó bạn không cần phải phụ thuộc vào những gì được cài đặt trên server.

Việc đóng gói này giúp:

- Shipping container: ta có thể move container qua bất kì  device nào có docker mà không cần quan tâm nó chạy OS nào.
- **Docker đảm bảo mọi người trong đều làm việc trên cùng một môi trường, giảm thiểu sự cố "it works on my machine".**
- Containers isolate: các container và hệ thống system gần như không liên quan gì đến nhau giúp tăng tính bảo mật, và các xung đột

Ngoài ra docker còn 1 số lợi ích khác:

- light weight : Các container chia sẻ host OS kernel, giúp chúng hiệu quả hơn các virtual machine truyền thống.

- Version control: docker có phép gắn tag version, giúp ta phân loại và dễ roll back nếu cần

- Microservices architecture, Scalability, Large ecosystem, …

## III Docker architecture

![Untitled](https://docs.docker.com/guides/images/docker-architecture.webp)

Docker client: docker client cho phép user tương tác với docker có thể thông qua:

- cli
- docker-desktop

Docker host: chính là OS mà docker running

Docker Daemon (Docker): sẽ listen các request từ docker client và quản lí các object: network, volume, image, container. Ngoài ra các deamon có thể communication với deamon khác để quản lí Docker service

Docker registries: là nơi lưu trữ các docker image, docker hub là 1 public registry, ngoài ra ta có thể tạo registry cho riêng mình nếu muốn

## IV Deep Dive

Phần này đi vào quá trình hình thành container và 1 số object liên quan như volume, network

![](https://lh6.googleusercontent.com/H8mhf23JNy-zCPrLaNs_H4h6K1xLRHv-P0JS4_Ad86xSo7En4tLT3POuOJPrcBNXG5lWDy2Y6fdNzRrzoB9SSLxrHhwrdk-qO28__D19NzO01OkkyBdr7YzZo2K_46HidAoUpmxeW2FOF42uOtAg3Pnfe_gcWafYs7xYywgdFeRdK3kV-p7LfIY7Z9h9tg)

### **1. Docker File**
#### **Định Nghĩa**
Docker file không phải là docker object, deamon không quản lí nó nhưng nó là sự khởi đầu của mọi thứ
Docker file chính là file chứa các chỉ dẫn, các bước để cho docker deamon biết cần phải làm gì để tạo ra image, hay còn gọi là docker file dùng để build image

⇒ user viết docker file ⇒ deamon làm theo các bước ⇒ docker image

#### **Example:**

![Untitled](/imgs/dockerfile.png)

#### **Cache layer**
Docker sử dụng hệ thống layer và caching để tối ưu quá trình build. Mỗi lệnh trong Dockerfile tạo ra một layer mới. Layers được cache và tái sử dụng trong các lần build tiếp theo.

Cách Docker sử dụng cache

+ Kiểm tra cache:
Mỗi lần rebuilt Docker kiểm tra từng layer từ trên xuống xem có layer cache nào khớp với lệnh hiện tại không.
+ Cache hit:
Nếu tìm thấy cache match, Docker sẽ sử dụng layer đã cache.
Tất cả các layer con của layer này cũng sẽ được sử dụng từ cache.
+ Cache miss: Nếu không tìm thấy cache match, Docker sẽ thực thi lệnh và tạo layer mới.
Tất cả các lệnh tiếp theo sẽ tạo layer mới, không sử dụng cache.

#### **Optimine Building**
Tối ưu Dockerfile là một bước quan trọng để giảm kích thước image và tăng hiệu suất build. Dưới đây là một số kỹ thuật chính:
+ Sử dụng base image phù hợp: Chọn image nhỏ gọn như Alpine Linux thay vì các bản distro đầy đủ.
+ Kết hợp các lệnh RUN: Gộp nhiều lệnh RUN thành một để giảm số lượng layer.
    + EX:
    ```shell
    # Không tối ưu
    RUN apt-get update
    RUN apt-get install -y package1
    RUN apt-get install -y package2
    # Tối ưu
    RUN apt-get update && \
    apt-get install -y package1 package2
    ```
+ Sử dụng .dockerignore: Loại bỏ các file không cần thiết khi build.
+ Sắp xếp các layer hợp lý: Đặt các layer ít thay đổi ở trên để tận dụng cache hiệu quả.
+ Sử dụng ARG cho các biến build-time: Giúp tái sử dụng Dockerfile cho nhiều version khác nhau.
+ Multi-stage builds: cho phép tạo image nhỏ gọn hơn bằng cách sử dụng nhiều stage trong một Dockerfile.
    + Ex:
    ```dockerfile
    # Stage 1: Build
    FROM golang:1.16 AS builder
    WORKDIR /app
    COPY . .
    RUN go build -o myapp

    # Stage 2: Run
    FROM alpine:3.14
    COPY --from=builder /app/myapp /usr/local/bin/myapp
    CMD ["myapp"]
    ```
### **2. Docker image**

#### **Định Nghĩa**

Docker image như 1 snapshot lúc build hoàn thành.

**Tại sao lại snapshot mà không phải running?**

Tưởng tượng theo nghĩa đen image là 1 bức ảnh, những gì xảy ra trong bức ảnh tại thời điểm chụp đó sẽ không bao giờ thay đổi ⇒ immutable 

 Vậy nên image giúp ta có thể:

- Tạo các container giống nhau trên các máy khác nhau từ cùng image
- Versioning: Có thể đáng tag image, giúp dễ dàng roll back
- Immutability: Sau khi được build, image là immutable, đảm bảo tính nhất quán trong các lần triển khai

#### **Example:**

Tạo image từ Dockerfile:

`docker build -t tên_image:tag path_docker_file`

Liệt kê các images: `docker images`

Xóa một image: `docker rmi tên_image:tag`

Xóa tất cả image đang không có container nào sử dụng: `docker image prune`

Tạo tag mới cho image: `docker tag image_nguồn:tag image_đích:tag`

Đẩy image lên Docker Hub hoặc registry khác: `docker push tên_image:tag`

Kéo image từ Docker Hub hoặc registry: `docker pull tên_image:tag`

Xem thông tin chi tiết của image: `docker inspect tên_image:tag`

Xem lịch sử các layer của image: `docker history tên_image:tag`

### **3. Docker Container**

#### **Định Nghĩa**

Container là running instance of docker image, cung cấp một môi trường biệt lập để ứng dụng chạy nhất quán trên các môi trường máy tính khác nhau.

#### **Example:**

- Tạo và chạy container:

    `docker run -d --name tên_container tên_image:tag`
    
  -d là detach nghĩa là container sẽ chạy nền
    
    -a là attach container sẽ hold terminal để running
    
- Liệt kê các container đang chạy: `docker ps`
- Liệt kê tất cả containers (cả đang chạy và đã dừng): `docker ps -a`

- stop container: `docker stop tên_container`
- Khởi động lại một container đã stop: `docker start tên_container`

- Tạm dừng một container: `docker pause tên_container`
- Bỏ tạm dừng một container: `docker unpause tên_container`

- Xóa một container: `docker rm tên_container`
- Xóa tất cả containers đã dừng: `docker container prune`

- access shell của container đang chạy:

    `docker exec -it tên_container /bin/bash`

- Xem thông tin chi tiết của container: `docker inspect tên_container`
- Xem tài nguyên sử dụng của containers: `docker stats`

- Tạo image từ container: `docker commit tên_container tên_image_mới:tag`

- copy from container → host:

    `docker cp tên_container:/container_path /host_path`

### **4. Docker Data**

**1 application running bắt buộc phải lưu trữ dự liệu, vậy trong docker, ta làm thế nào??**

![](https://docs.docker.com/storage/images/types-of-mounts-bind.webp)

Trong Docker container, có ba cách chính để lưu trữ dữ liệu:

1. Volumes: là 1 cơ chế lưu trữ dự liệu do docker quản lí, ta chỉ cần khai báo, và toàn bộ việc còn lại docker sẽ quản lí.
    - 1 Volume có thể share cho nhiều container.
    - Volumes ko phụ thuộc vòng đời của container, nghĩa là dữ liệu trong volume không bị mất khi container bị xóa.
    - Dữ liệu bên trong volume sẽ được docker mã hóa, và chính vì tách biệt với container nên có thể sao lưu dễ dàng
    - Có 2 loại volume là name volume(user đặt tên cho volume) và anonymouse volume(user ko đặt tên nên docker sẽ gen ra 1 random name)
    - Ex khởi tạo volume:
        - Tạo volume 1 mình:  `docker volume create my_volume`
        - khởi tạo name volume(hoặc gắn 1 volume) khi run container :
    
            `docker run -v volume:/container/path --name container_name image_name`
    
        - khởi tạo anonymous volume khi run container:
    
            `docker run -v /container/path --name container_name image_name`
    
    - Ex tương tác với volume:
        - Xem danh sách volume:  `docker volume ls`
        - Xem chi tiết volume: `docker volume inspect my_volume`  ( không thể xem volume đang được dùng bởi container nào) muốn xem thì phải inspect container để biết nó đang dùng volume nào
        - Xóa volume: `docker volume rm my_volume`
        - Xóa tất cả volume không sử dụng `docker volume prune`
1. Bind Mounts:
    - Docker bind mount là một cơ chế cho phép bạn gắn (mount) một thư mục hoặc tệp từ hệ thống máy chủ (host) vào bên trong một container. Đây là cách trực tiếp để chia sẻ dữ liệu giữa máy chủ và container.
    - Mount thư mục với container 
    
        `docker run -v host/past:/container/path --name container_name image_name`
2. tmpfs Mounts:
    - Nếu như ta running docker trên Linux ta có thể dùng tmpfs mount. Container có thể tạo các file trên host, tuy nhiên chỉ có thể coi là tạm thời, khi container stop thì tmpfs mount cũng sẽ bị mất
    - EX:
        ```shell
        docker run -d \
        -it \
        --name tmptest \
        --mount type=tmpfs,destination=/app \
        nginx:latest
        ```
    
#### So sánh các loại mount trong Docker

| Tính năng | Volume | Bind Mount | tmpfs Mount |
|-----------|--------|------------|-------------|
| **Vị trí lưu trữ** | Được quản lý bởi Docker | Bất kỳ đâu trên filesystem host | Bộ nhớ của host system |
| **Windows support** | Có | Có | Không |
| **Share giữa containers** | Có | Có | Không |
| **Tính năng drivers** | Có | Không | Không |
| **Hiệu suất** | Tạm | Tốt nhất | Tốt (RAM) |
| **Tính di động** | Cao | Thấp | Không |
| **Dữ liệu tồn tại khi container dừng** | Có | Có | Không |
| **Sao lưu** | Dễ dàng | Phụ thuộc vào host | Không áp dụng |
| **Nội dung được điền trước** | Có thể | Có | Không |
| **Phù hợp cho** | Dữ liệu ứng dụng | Cấu hình, mã nguồn | Dữ liệu tạm thời |

#### Khi nào sử dụng:
+ Volume
    - Khi cần chia sẻ dữ liệu giữa nhiều containers
    - Khi cần sao lưu hoặc di chuyển dữ liệu dễ dàng
    - Khi cần quản lý dữ liệu độc lập với host machine

+ Bind Mount
    - Trong quá trình phát triển để chia sẻ mã nguồn
    - Khi cần truy cập trực tiếp vào cấu hình của host

+ tmpfs Mount
    - Khi cần lưu trữ tạm thời, không cần lưu trữ lâu dài
    - Khi xử lý dữ liệu nhạy cảm không muốn lưu trên disk

### **5. Docker Network**
Docker network là chức năng thiết yếu để quản lí giao tiếp giữa các container hoặc giữa container với host thông qua các network driver.
#### Các loại network trong Docker
 1. Bridge Network:
    - Mặc định cho container
    - Cho phép container trên cùng một host giao tiếp với nhau
    - Sử dụng NAT để kết nối ra bên ngoài

 2. Host Network
    - Container sử dụng network stack của host
    - Hiệu suất tốt nhất nhưng ít isolate nhất

3. None Network
    - Container không có kết nối mạng
    - Hoàn toàn bị cô lập

4. Overlay Network
    - Cho phép container trên các host Docker khác nhau giao tiếp với nhau
    - Sử dụng trong Docker Swarm

5. Macvlan Network
    - Gán địa chỉ MAC cho container
    - Container xuất hiện như một thiết bị vật lý trên mạng

#### **Example:**
- Liệt kê networks: `docker network ls`
- Tạo network: `docker network create [OPTIONS] NETWORK`
- Xóa network: `docker network rm NETWORK`
- Kết nối container với network: `docker network connect NETWORK CONTAINER`
- Ngắt kết nối: `docker network disconnect NETWORK CONTAINER`
- Kiểm tra chi tiết: `docker network inspect NETWORK`
