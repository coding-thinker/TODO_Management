CREATE DATABASE TODO;
USE TODO;
CREATE TABLE UserList(
uno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
uname VARCHAR(20) NOT NULL UNIQUE,
upassword VARCHAR(20) NOT NULL,
email VARCHAR(30) NOT NULL
)
AUTO_INCREMENT = 100000;

CREATE TABLE GroupList ( 
	gno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT, 
	gname VARCHAR ( 20 ) NOT NULL 
) AUTO_INCREMENT = 200000;

CREATE TABLE GrouppersonList (
	gpno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
	gp_gno INT UNSIGNED NOT NULL,
	gp_uno INT UNSIGNED NOT NULL,
	leader ENUM ( '0', '1' ) NOT NULL DEFAULT '0',
	FOREIGN KEY ( gp_uno ) REFERENCES UserList ( uno ) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY ( gp_gno ) REFERENCES GroupList ( gno ) ON UPDATE CASCADE ON DELETE CASCADE 
) 
AUTO_INCREMENT = 600000;

-- 创建个人任务列表
CREATE TABLE PTaskList(
ptno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
pt_uno INT UNSIGNED NOT NULL,
ptname VARCHAR(20) NOT NULL,
ptbegintime DATETIME NOT NULL,
ptendtime DATETIME NOT NULL,
ptfinishtime DATETIME,
ptfinishflag ENUM('0','1') NOT NULL DEFAULT '0',
ptrepeatflag ENUM('0','1') NOT NULL DEFAULT '0',
ptrepeattype ENUM('none','day','week','month') NOT NULL DEFAULT 'none',
ptrepeattimes SMALLINT NOT NULL DEFAULT 0,
ptimportance TINYINT NOT NULL DEFAULT 1,
FOREIGN  KEY(pt_uno) references UserList(uno) ON UPDATE CASCADE ON DELETE CASCADE
)
AUTO_INCREMENT = 300000;

-- 创建组任务列表
CREATE TABLE GTaskList(
gtno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
gt_uno INT UNSIGNED NOT NULL,
gtname VARCHAR(20) NOT NULL,
gtbegintime DATETIME NOT NULL,
gtendtime DATETIME NOT NULL,
gtfinishtime DATETIME,
gtfinishflag ENUM('0','1') NOT NULL DEFAULT '0',
gtrepeatflag ENUM('0','1') NOT NULL DEFAULT '0',
gtrepeattype ENUM('none','day','week','month') NOT NULL DEFAULT 'NONE',
gtrepeattimes SMALLINT NOT NULL DEFAULT 0,
gtimportance TINYINT DEFAULT 1,
FOREIGN  KEY(gt_uno) references GroupList(gno) ON UPDATE CASCADE ON DELETE CASCADE
)
AUTO_INCREMENT = 400000;

-- 创建组子任务列表
CREATE TABLE SubTaskList(
sno INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
s_gno INT UNSIGNED NOT NULL, 
s_uno INT UNSIGNED NOT NULL,
sname VARCHAR(20) NOT NULL,
sbegintime DATETIME NOT NULL,
sendtime DATETIME NOT NULL,
sfinishtime DATETIME,
sfinishflag ENUM('0','1') NOT NULL DEFAULT '0',
srepeatflag ENUM('0','1') NOT NULL DEFAULT '0',
srepeattype ENUM('none','day','week','month'),
srepeattimes SMALLINT NOT NULL DEFAULT 0,
simportance TINYINT DEFAULT 1,
FOREIGN  KEY(s_gno) references GTaskList(gtno) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN  KEY(s_uno) references UserList(uno) ON UPDATE CASCADE ON DELETE CASCADE
)
AUTO_INCREMENT = 500000;

delimiter $

/************触发器 组任务完成 子任务全部完成******/
CREATE TRIGGER FINISHALL AFTER UPDATE ON gtasklist
FOR EACH ROW
BEGIN
IF NEW.gtfinishflag = '1' THEN
		UPDATE subtasklist SET sfinishflag = '1' WHERE s_gno = NEW.gtno;
		UPDATE subtasklist SET sfinishtime = CURRENT_TIMESTAMP() WHERE s_gno = NEW.gtno AND sfinishtime is NULL;
END IF;
END$

/**************存储过程*****************/
-- 完成个人任务 存储过程 更新状态标志和完成时间
CREATE PROCEDURE PERSONFINISH (IN f_ptno INT UNSIGNED)
BEGIN
UPDATE ptasklist SET ptfinishflag = '1' WHERE ptno = f_ptno;
UPDATE ptasklist SET ptfinishtime = CURRENT_TIMESTAMP() WHERE ptno = f_ptno;
END$

-- 完成组任务 存储过程 更新状态标志和完成时间
CREATE PROCEDURE GROUPFINISH(IN f_gtno INT UNSIGNED)
BEGIN 
UPDATE gtasklist SET gtfinishflag = '1' WHERE gtno = f_gtno;
UPDATE gtasklist SET gtfinishtime = CURRENT_TIMESTAMP() WHERE gtno = f_gtno;
END$

-- 组任务每天重复的任务
CREATE PROCEDURE G_DAYREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gtuno INT UNSIGNED,IN f_gtname VARCHAR(20),IN f_gtimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT DAY);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT DAY);
			INSERT INTO GTaskList(gtno,gt_uno,gtname,gtbegintime,gtendtime,gtimportance) VALUES(NULL,f_gtuno,f_gtname,RESULTBEGIN,RESULTEND,f_gtimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 组任务每周重复的任务
CREATE PROCEDURE G_WEEKREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gtuno INT UNSIGNED,IN f_gtname VARCHAR(20),IN f_gtimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT WEEK);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT WEEK);
			INSERT INTO GTaskList(gtno,gt_uno,gtname,gtbegintime,gtendtime,gtimportance) VALUES(NULL,f_gtuno,f_gtname,RESULTBEGIN,RESULTEND,f_gtimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 组任务每月重复的任务
CREATE PROCEDURE G_MONTHREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gtuno INT UNSIGNED,IN f_gtname VARCHAR(20),IN f_gtimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT MONTH);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT MONTH);
			INSERT INTO GTaskList(gtno,gt_uno,gtname,gtbegintime,gtendtime,gtimportance) VALUES(NULL,f_gtuno,f_gtname,RESULTBEGIN,RESULTEND,f_gtimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 个人任务每天重复的任务
CREATE PROCEDURE P_DAYREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_ptuno INT UNSIGNED,IN f_ptname VARCHAR(20),IN f_ptimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT DAY);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT DAY);
			INSERT INTO PTaskList(ptno,pt_uno,ptname,ptbegintime,ptendtime,ptimportance) VALUES(NULL,f_ptuno,f_ptname,RESULTBEGIN,RESULTEND,f_ptimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 个人任务每周重复的任务
CREATE PROCEDURE P_WEEKREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_ptuno INT UNSIGNED,IN f_ptname VARCHAR(20),IN f_ptimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT WEEK);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT WEEK);
			INSERT INTO PTaskList(ptno,pt_uno,ptname,ptbegintime,ptendtime,ptimportance) VALUES(NULL,f_ptuno,f_ptname,RESULTBEGIN,RESULTEND,f_ptimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 个人任务每月重复的任务
CREATE PROCEDURE P_MONTHREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_ptuno INT UNSIGNED,IN f_ptname VARCHAR(20),IN f_ptimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT MONTH);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT MONTH);
			INSERT INTO PTaskList(ptno,pt_uno,ptname,ptbegintime,ptendtime,ptimportance) VALUES(NULL,f_ptuno,f_ptname,RESULTBEGIN,RESULTEND,f_ptimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 组子任务每天重复的任务
CREATE PROCEDURE S_DAYREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gno INT UNSIGNED,IN f_uno INT UNSIGNED,IN f_sname VARCHAR(20),IN f_stimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT DAY);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT DAY);
			INSERT INTO SubTaskList(sno,s_gno,s_uno,sname,sbegintime,sendtime,simportance) VALUES(NULL,f_gno,f_uno,f_sname,RESULTBEGIN,RESULTEND,f_stimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 组子任务每周重复的任务
CREATE PROCEDURE S_WEEKREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gno INT UNSIGNED,IN f_uno INT UNSIGNED,IN f_sname VARCHAR(20),IN f_stimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT WEEK);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT WEEK);
			INSERT INTO SubTaskList(sno,s_gno,s_uno,sname,sbegintime,sendtime,simportance) VALUES(NULL,f_gno,f_uno,f_sname,RESULTBEGIN,RESULTEND,f_stimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 组子任务每月重复的任务
CREATE PROCEDURE S_MONTHREP(IN in_count SMALLINT,IN BEGINTIME DATETIME,IN ENDTIME DATETIME,IN f_gno INT UNSIGNED,IN f_uno INT UNSIGNED,IN f_sname VARCHAR(20),IN f_stimportance TINYINT)
BEGIN
		DECLARE f_COUNT INT;
		DECLARE RESULTBEGIN DATETIME;
		DECLARE RESULTEND DATETIME;
		SET f_COUNT = 1;
		WHILE f_COUNT <= in_count DO
			SET RESULTBEGIN = DATE_ADD(BEGINTIME,INTERVAL f_COUNT MONTH);
			SET RESULTEND = DATE_ADD(ENDTIME,INTERVAL f_COUNT MONTH);
			INSERT INTO SubTaskList(sno,s_gno,s_uno,sname,sbegintime,sendtime,simportance) VALUES(NULL,f_gno,f_uno,f_sname,RESULTBEGIN,RESULTEND,f_stimportance);
			SET f_COUNT = f_COUNT + 1;
		END WHILE;
END$

-- 找出任务可分配成员
create procedure in_param(in G_TASK_ID int)
begin
select gp_uno from grouppersonlist whrere where gp_gno=(select gt_uno from gtasklist WHERE gt_uno=G_TASK_ID);
end$

-- 给定组号，查询该组成员名称，对应分配的子任务名称，以及子任务完成情况
CREATE PROCEDURE getsubtask ( IN gno INT ( 10 ) UNSIGNED ) BEGIN
	SELECT
		userlist.uname,
		subtasklist.sname,
		subtasklist.sfinishflag 
	FROM
		userlist,
		grouppersonlist,
		gtasklist,
		subtasklist 
	WHERE
		grouppersonlist.gp_gno = gno
		and grouppersonlist.gp_uno = userlist.uno
		and gtasklist.gt_uno = gno
		and gtasklist.gtno = subtasklist.s_gno;
END$

delimiter ;

/***********视图**************/
-- 个人任务已完成视图
CREATE VIEW pfinished AS SELECT * 
FROM ptasklist 
WHERE ptfinishflag = '1'; 

-- 个人任务未完成视图
CREATE VIEW punfinished AS SELECT * 
FROM ptasklist 
WHERE ptfinishflag = '0';



-- /************插入数据*************/
-- userlist（用户表）
INSERT INTO UserList VALUES(NULL,'WANG','WANG123','wangwangwang@swjtu.edu.cn');
INSERT INTO UserList VALUES(NULL,'Liuyuxi','Liuyuxi11','lyx@swjtu.edu.cn');
INSERT INTO UserList VALUES(NULL,'maqianzhu','guowuqin99','gwq@lgqm.org');
INSERT INTO UserList VALUES(NULL,'tom-the-cat','jerry-the-mouse','nomail@mail.example.com');
INSERT INTO UserList VALUES(NULL,'wangyangfan','yangfanwang','yfw@fdu.edu.cn');
INSERT INTO UserList VALUES(NULL,'ponyma','huatengma','pony@qq.com');
INSERT INTO UserList VALUES(NULL,'jackma','alibaba','ceo@alibaba.com');
INSERT INTO UserList VALUES(NULL,'DonaldTrump','president2020failed','trump@zhanhuju.org');
INSERT INTO UserList VALUES(NULL,'zhukezhen','laoxiaozhang','kzz@zju.edu.cn');
INSERT INTO UserList VALUES(NULL,'hang14zhong','1414hangzhou','top4@h14z.com');
INSERT INTO UserList VALUES(NULL,'bianbuchulaile','woluanxieba1','luanxiede@zheyehsi.luanxie.de');
INSERT INTO UserList VALUES(NULL,'zaodianfangjiaba','qiuqiunile','vacation@holiday.com');
INSERT INTO UserList VALUES(NULL,'Guido','pythonisthebest','gudio@gmail.com');
INSERT INTO UserList VALUES(NULL,'ICU996','dieinternationale','996icu@icu.org');
INSERT INTO UserList VALUES(NULL,'codebar','githubMicrosoft','github@outlook.com');
INSERT INTO UserList VALUES(NULL,'timgroup','qqoverwechat','nowechat@qq.com');
INSERT INTO UserList VALUES(NULL,'vscodemanager','vscodebettersvs','vs-code@outlook.com');
INSERT INTO UserList VALUES(NULL,'changsanjiao','jiangzhehu','jzh@163.com');
INSERT INTO UserList VALUES(NULL,'neteasemusic','powerofmusic','music-team@163.com');
INSERT INTO UserList VALUES(NULL,'bianwanle','tongkudaotoule','xiexieshijie@zhongyu.xiewan.la');

-- DELETE FROM GROUPLIST
-- grouplist（组表）
INSERT INTO grouplist VALUES(NULL,'复兴交大组');
INSERT INTO grouplist VALUES(NULL,'产率为0组');
INSERT INTO grouplist VALUES(NULL,'服务器又崩了组');
INSERT INTO grouplist VALUES(NULL,'123很ok');
INSERT INTO grouplist VALUES(NULL,'住在实验室里真不戳组');
-- 
-- -- grouppersonlist（组成员表）
INSERT INTO grouppersonlist(gp_gno,gp_uno,leader) VALUES(200001,100001,'1');
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200001,100002);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200001,100003);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200001,100004);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200001,100005);
INSERT INTO grouppersonlist(gp_gno,gp_uno,leader) VALUES(200002,100006,'1');
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200002,100007);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200002,100008);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200002,100009);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200002,100010);
INSERT INTO grouppersonlist(gp_gno,gp_uno,leader) VALUES(200003,100011,'1');
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200003,100012);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200003,100013);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200003,100014);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200003,100015);
INSERT INTO grouppersonlist(gp_gno,gp_uno,leader) VALUES(200004,100016,'1');
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200004,100017);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200004,100018);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200004,100019);
INSERT INTO grouppersonlist(gp_gno,gp_uno) VALUES(200004,100000);

-- ptasklist（个人任务表）
INSERT INTO PTaskList VALUES(NULL,100001,'测试用个人任务（不重复）',20201212000000,20201213000000,NULL,'0','0','none',0,5);
INSERT INTO PTaskList VALUES(NULL,100002,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','1','day',2,2);
INSERT INTO PTaskList VALUES(NULL,100003,'测试用个人任务（周重复）',20201212000000,20201213000000,NULL,'0','1','month',3,3);
INSERT INTO PTaskList VALUES(NULL,100004,'测试用个人任务（月重复）',20201212000000,20201213000000,NULL,'0','1','week',6,4);
INSERT INTO PTaskList VALUES(NULL,100005,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','0','day',8,1);
INSERT INTO PTaskList VALUES(NULL,100006,'测试用个人任务（不重复）',20201212000000,20201213000000,NULL,'0','0','none',0,5);
INSERT INTO PTaskList VALUES(NULL,100007,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','1','day',2,2);
INSERT INTO PTaskList VALUES(NULL,100008,'测试用个人任务（周重复）',20201212000000,20201213000000,NULL,'0','1','month',3,3);
INSERT INTO PTaskList VALUES(NULL,100009,'测试用个人任务（月重复）',20201212000000,20201213000000,NULL,'0','1','week',6,4);
INSERT INTO PTaskList VALUES(NULL,100010,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','0','day',8,1);
INSERT INTO PTaskList VALUES(NULL,100011,'测试用个人任务（不重复）',20201212000000,20201213000000,NULL,'0','0','none',0,5);
INSERT INTO PTaskList VALUES(NULL,100012,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','1','day',2,2);
INSERT INTO PTaskList VALUES(NULL,100013,'测试用个人任务（周重复）',20201212000000,20201213000000,NULL,'0','1','month',3,3);
INSERT INTO PTaskList VALUES(NULL,100014,'测试用个人任务（月重复）',20201212000000,20201213000000,NULL,'0','1','week',6,4);
INSERT INTO PTaskList VALUES(NULL,100015,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','0','day',8,1);
INSERT INTO PTaskList VALUES(NULL,100016,'测试用个人任务（不重复）',20201212000000,20201213000000,NULL,'0','0','none',0,5);
INSERT INTO PTaskList VALUES(NULL,100017,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','1','day',2,2);
INSERT INTO PTaskList VALUES(NULL,100018,'测试用个人任务（周重复）',20201212000000,20201213000000,NULL,'0','1','month',3,3);
INSERT INTO PTaskList VALUES(NULL,100019,'测试用个人任务（月重复）',20201212000000,20201213000000,NULL,'0','1','week',6,4);
INSERT INTO PTaskList VALUES(NULL,100000,'测试用个人任务（日重复）',20201212000000,20201213000000,NULL,'0','0','day',8,1);

-- gtasklist 组任务表
INSERT INTO GTaskList(gtno,gt_uno,gtname,gtbegintime,gtendtime,gtimportance) VALUES(NULL,200001,'测试用组不重复任务1',20201212000000,20201213000000,5);
INSERT INTO GTaskList(gtno,gt_uno,gtname,gtbegintime,gtendtime,gtimportance) VALUES(NULL,200002,'测试用组不重复任务2',20201212000000,20201213000000,3);
INSERT INTO GTaskList VALUES (NULL,200003,'测试用组重复任务（天）',20201212000000,20201213000000,NULL,'0','1','DAY',2,5);
INSERT INTO GTaskList VALUES (NULL,200004,'测试用组重复任务（周）',20201212000000,20201213000000,NULL,'0','1','WEEK',2,3);
INSERT INTO GTaskList VALUES (NULL,200000,'测试用组重复任务（月）',20201212000000,20201213000000,NULL,'0','1','MONTH',2,2);


-- subtasklist 子任务列表
INSERT INTO subtasklist VALUES(NULL,400001,100001,'组1测试用子任务（日重复）','20201212000000','20201213000000',NULL,'0','1','day',2,5);
INSERT INTO subtasklist VALUES(NULL,400001,100002,'组1测试用子任务（周重复）','20201212000000','20201213000000',NULL,'0','1','WEEK',2,4);
INSERT INTO subtasklist VALUES(NULL,400001,100003,'组1测试用子任务（月重复）','20201212000000','20201213000000',NULL,'0','1','MONTH',2,3);
INSERT INTO subtasklist VALUES(NULL,400001,100004,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);
INSERT INTO subtasklist VALUES(NULL,400001,100005,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);

INSERT INTO subtasklist VALUES(NULL,400002,100006,'组1测试用子任务（日重复）','20201212000000','20201213000000',NULL,'0','1','day',2,5);
INSERT INTO subtasklist VALUES(NULL,400002,100007,'组1测试用子任务（周重复）','20201212000000','20201213000000',NULL,'0','1','WEEK',2,4);
INSERT INTO subtasklist VALUES(NULL,400002,100008,'组1测试用子任务（月重复）','20201212000000','20201213000000',NULL,'0','1','MONTH',2,3);
INSERT INTO subtasklist VALUES(NULL,400002,100009,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);
INSERT INTO subtasklist VALUES(NULL,400002,100010,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);

INSERT INTO subtasklist VALUES(NULL,400003,100011,'组1测试用子任务（日重复）','20201212000000','20201213000000',NULL,'0','1','day',2,5);
INSERT INTO subtasklist VALUES(NULL,400003,100012,'组1测试用子任务（周重复）','20201212000000','20201213000000',NULL,'0','1','WEEK',2,4);
INSERT INTO subtasklist VALUES(NULL,400003,100013,'组1测试用子任务（月重复）','20201212000000','20201213000000',NULL,'0','1','MONTH',2,3);
INSERT INTO subtasklist VALUES(NULL,400003,100014,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);
INSERT INTO subtasklist VALUES(NULL,400003,100015,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);

INSERT INTO subtasklist VALUES(NULL,400004,100016,'组1测试用子任务（日重复）','20201212000000','20201213000000',NULL,'0','1','day',2,5);
INSERT INTO subtasklist VALUES(NULL,400004,100017,'组1测试用子任务（周重复）','20201212000000','20201213000000',NULL,'0','1','WEEK',2,4);
INSERT INTO subtasklist VALUES(NULL,400004,100018,'组1测试用子任务（月重复）','20201212000000','20201213000000',NULL,'0','1','MONTH',2,3);
INSERT INTO subtasklist VALUES(NULL,400004,100019,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);
INSERT INTO subtasklist VALUES(NULL,400004,100000,'组1测试用子任务（不重复）','20201212000000','20201213000000',NULL,'0','1','none',0,5);

/****** 一键完成触发器测试 ********/
UPDATE gtasklist SET gtfinishflag = '1' WHERE GTNO = 400001;


-- /********存储过程测试************/
-- -- 个人任务完成
-- CALL PERSONFINISH(300005)
-- -- 组任务完成
-- CALL GROUPFINISH(400001)
-- 
-- -- 组任务每天重复任务
-- CALL G_DAYREP(2,20201212000000,20201213000000,200003,'测试用组重复任务(天)',5)
-- -- 组任务每周重复任务
-- CALL G_WEEKREP(2,20201212000000,20201213000000,200004,'测试用组重复任务(周)',3)
-- -- 组任务每月重复任务
-- CALL G_MONTHREP(2,20201212000000,20201213000000,200000,'测试用组重复任务(月)',2)
-- 
-- -- 个人任务每天重复任务
-- CALL P_DAYREP(2,20201212000000,20201213000000,100007,'测试用组重复任务(天)',2)
-- -- 个人任务每周重复任务
-- CALL P_WEEKREP(6,20201212000000,20201213000000,100009,'测试用组重复任务(周)',4)
-- -- 个人任务每月重复任务
-- CALL P_MONTHREP(3,20201212000000,20201213000000,100008,'测试用组重复任务(月)',3)
-- 
-- -- 组子任务每天重复任务
-- CALL S_DAYREP(2,20201212000000,20201213000000,400002,100006,'子任务重复任务(天)',5)
-- -- 组子任务每周重复任务
-- CALL S_WEEKREP(2,20201212000000,20201213000000,400003,100012,'子任务重复任务(周)',4)
-- -- 组子任务每月重复任务
-- CALL S_MONTHREP(2,20201212000000,20201213000000,400004,100018,'子任务重复任务(月)',3)
-- 
-- -- 找出可分配成员 给定组ID
-- CALL IN_PARAM(200002)
-- 
-- -- 给定组号，查询该组成员名称，对应分配的子任务名称，以及子任务完成情况
-- CALL getsubtask (200002)