#STEP-1:installing git maven java
yum install git maven java-1.8.0 -y
#STEP-2: GETTING THE REPO (jenkins.io --> download -- > redhat)
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#STEP-3: DOWNLOAD JAVA AND JENKINS
yum install jenkins java-17 -y
update-alternatives --config java
#STEP-4: RESTARTING JENKINS (when we download service it will on stopped state)
systemctl start jenkins
chkconfig jenkins on
systemctl status jenkins
