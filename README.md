# Sakila-DB

1. 创建视图，返回最近一个月，被租借最多前五名的电影DVD信息；
2. 创建视图，返回最近一个月，租借DVD用户排名，并按照所在国家、城市进行分组排序；
3. 创建视图，返回最近一个月，被租借DVD电影类型排名，显示租赁的次数；
4. 创建一个函数，输入客户姓名，返回应付租金；
5. 创建一个函数，输入商店ID，返回该商店租赁DVD总利润，总利润=总收入-员工成本，员工成本=员工工资*月数，员工工资=10美元/月；
6. 创建一个触发器，当一个DVD电影删除，相关该DVD的记录设置为无效状态。（可对相关表增加字段）
7. 创建一个触发器，当对租赁DVD表中的数据进行修改时，在另外一个表（可以自己定义增加），记录修改的行为，包括修改的字段，原来的值，修改后的值，发生的时间。
8. 建立一个统计表，针对每天的租赁行为进行统计，统计所有商店的租赁业务，具体内容包括租赁DVD名称，数量，收入，租赁日期。该统计过程可通过存储过程来实现，每天进行统计，可用Mysql里的任务机制实现。
