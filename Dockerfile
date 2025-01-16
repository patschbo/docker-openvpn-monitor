FROM debian:bookworm-slim AS main

ENV CONFD_VERSION=0.16.0

COPY requirements.txt /tmp/requirements.txt

RUN apt-get update \
&& apt-get install -y wget python3 python3-pip python3.11-venv

RUN mkdir /openvpn-monitor \
&& cd /openvpn-monitor \
&& python3 -m venv .venv \
&& . .venv/bin/activate \
&& .venv/bin/pip3 install --upgrade pip --no-cache-dir \
&& .venv/bin/pip3 install -r /tmp/requirements.txt

RUN wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 \
&& chmod +x /usr/local/bin/confd

RUN  mkdir -p /var/lib/GeoIP/
ADD https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb /var/lib/GeoIP/

RUN rm -rf /var/lib/apt/lists/

COPY openvpn-monitor.conf.example /etc/openvpn-monitor/openvpn-monitor.conf
COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD [".venv/bin/gunicorn","openvpn_monitor.app", "--bind", "0.0.0.0:80"]
