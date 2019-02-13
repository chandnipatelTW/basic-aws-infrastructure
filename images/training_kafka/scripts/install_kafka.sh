# Add Confluent Repo
REPO_URL=https://packages.confluent.io/rpm

sudo rpm --import ${REPO_URL}/${CONFLUENT_PLATFORM_VERSION}/archive.key

cat | sudo tee -a /etc/yum.repos.d/confluent.repo > /dev/null << EOF
[Confluent.dist]
name=Confluent repository (dist)
baseurl=${REPO_URL}/${CONFLUENT_PLATFORM_VERSION}/7
gpgcheck=1
gpgkey=${REPO_URL}/${CONFLUENT_PLATFORM_VERSION}/archive.key
enabled=1

[Confluent]
name=Confluent repository
baseurl=${REPO_URL}/${CONFLUENT_PLATFORM_VERSION}
gpgcheck=1
gpgkey=${REPO_URL}/${CONFLUENT_PLATFORM_VERSION}/archive.key
enabled=1
EOF

# Install Confluent platform
sudo yum clean all && sudo yum install -y confluent-platform-oss-${CONFLUENT_SCALA_VERSION}

sudo systemctl enable confluent-zookeeper
sudo systemctl enable confluent-kafka

# Install cloud watch agent prerequirement
sudo yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA.x86_64
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip && \
rm CloudWatchMonitoringScripts-1.2.2.zip && \
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-used --disk-space-avail --disk-space-util --disk-path=/ --from-cron") | crontab -
