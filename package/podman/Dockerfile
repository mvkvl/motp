FROM golang:bullseye

MAINTAINER "Mikhail Kantur” <mkantur@gmail.com>"
RUN apt update && apt install -y systemd zip && apt-get clean
CMD ["/bin/systemd"]
