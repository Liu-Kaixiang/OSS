CREATE DATABASE OSS
ON PRIMARY 
( NAME = oss_data, 
  FILENAME = 'D:\sql_data\oss_data.mdf', --�޸Ĵ˴洢·��
  SIZE = 10,
  MAXSIZE = 150,
  FILEGROWTH = 5%)

LOG ON
( NAME = oss_log,
  FILENAME = 'D:\sql_log\oss_log.ldf',   --�޸Ĵ˴洢·��
  SIZE = 2,
  MAXSIZE = 50,
  FILEGROWTH = 1);
GO

use OSS

create table user_inf
(user_id			int not null identity(1,1),
 username			varchar(25) not null unique,
 password			varchar(120) not null,
 nickname			varchar(25),
 phone				char(11) unique not null,
 avatar				varchar(50) default '/images/avatars/default.jpg', 
 sex				varchar(8) default '����',
 birthday			date,
 is_valid			bit not null default 1,
 primary key (user_id),
 check(sex in ('��','Ů','����')));

 create index ID_user_un on user_inf(username)

 create table admin_inf
(admin_id			int not null,
 password			varchar(120) not null,
 admin_name			varchar(20),
 primary key(admin_id));

create table transaction_inf
(transaction_id			int not null identity(1,1),
 user_id				int not null,
 admin_id				int,
 transaction_type		varchar(16) not null,
 transaction_status		varchar(10) not null,
 comment				varchar(300) not null,
 commit_time			datetime not null,
 complete_time			datetime,
 annotation				varchar(300),
 is_valid				bit not null default 1,
 primary key(transaction_id),
 constraint fk_apply foreign key (user_id) references user_inf(user_id) on delete no action on update cascade,
 constraint fk_handle foreign key(admin_id) references admin_inf(admin_id) on delete no action on update cascade,
 check(transaction_status in('δ����','��ͨ��','�Ѿܾ�')),
 check(transaction_type in('��������','�û�Ͷ��')));

create table shop
(shop_id				int not null identity(1,1),
 user_id				int not null,
 apply_status			varchar(10) not null default '�����',
 shop_name				varchar(90) not null,
 address				varchar(150) not null,
 phone					char(11) not null,
 shop_describe			varchar(300) default '��������',
 announcement			varchar(300) default '���޹���',
 evaluate_sum			bigint default 0,
 evaluate_number		bigint default 0,
 is_valid				bit not null default 1,
 primary key(shop_id),
 constraint fk_shop_to_user foreign key (user_id) references user_inf(user_id) on delete no action on update cascade,
 check(apply_status in('�����','��ͨ��','δͨ��')));

 create index ID_shop_uid on shop(user_id)


/*==============================================================*/
/* Table: goods                                                 */
/*==============================================================*/
create table goods
(
   goods_id             int not null identity(1,1),
   category_id          int not null,
   shop_id              int not null,
   goods_name           varchar(90) not null,
   sales                int not null default 0,
   discount_deadline    datetime default '2000-01-01 00:00:00',
   discount_rate        float default 1.00,
   is_valid             bit not null default 'TRUE',
   goods_describe       varchar(300),
   primary key (goods_id),
   constraint fk_refer foreign key (category_id)
      references category (category_id),
   constraint fk_sell foreign key (shop_id)
      references shop (shop_id)
);


/*==============================================================*/
/* Table: goods_image                                           */
/*==============================================================*/
create table goods_image
(
      image_id          int not null identity,
      goods_id          int not null,
      image_addr        varchar(50) not null,
      is_valid          bit not null default 1,
      primary key (image_id),
      constraint FK_goods_image foreign key (goods_id)
	    references goods (goods_id) 
);

create index index_goods_id on goods_image(goods_id);


/*==============================================================*/
/* Table: goods_attribute                                       */
/*==============================================================*/
create table goods_attribute
(
   attribute_id         int not null identity(1,1),
   attribute_value      varchar(90) not null,
   goods_id             int not null,
   cost                 float not null,
   price                float not null,
   inventory            int default 0,
   is_valid             bit not null default 1,
   primary key (attribute_id),
   constraint FK_attribute foreign key (goods_id)
      references goods (goods_id),
   check(inventory >= 0)
);
create index index_goods_id on goods_attribute(goods_id);

/*==============================================================*/
/* Table: goods_order                                           */
/*==============================================================*/
create table goods_order
(
   order_id             bigint not null identity(1,1),
   user_id              int not null,
   shop_id              int not null,
   order_status         varchar(10) not null default '������',
   tracking_number      char(12),
   pay_method           varchar(16) not null,
   order_time           datetime not null,
   complete_time        datetime,
   annotation           varchar(100),
   total                float not null,
   receiver_id          int not null,
   is_valid             bit not null default 1,
   primary key (order_id),
   constraint fk_manage_order foreign key (user_id)
      references user_inf (user_id),
   constraint fk_process_order foreign key (shop_id)
      references shop (shop_id),
   check(order_status in('������','������','���ջ�','������','�����','��ȡ��')),
   check(pay_method in('��������','����֧��'))
);
create index index_user_id on goods_order(user_id);


/*==============================================================*/
/* Table: goods_in_order                                        */
/*==============================================================*/
create table goods_in_order
(
   order_id             bigint not null,
   attribute_id         int not null,
   goods_id             int not null,
   goods_num            int not null,
   cost                 float not null,
   actual_price         float not null,
   comment              varchar(300),
   evaluate_score       smallint default 0,
   evaluate_time        datetime,
   primary key (attribute_id, order_id),
   constraint fk_contained_order foreign key (order_id)
      references goods_order (order_id),
   constraint fk_goods_id foreign key (goods_id)
      references goods (goods_id),
   constraint fk_attr_id foreign key (attribute_id)
      references goods_attribute (attribute_id),
   check(evaluate_score >= 0 and evaluate_score < 6)
);



/*==============================================================*/
/* Table: category                                              */
/*==============================================================*/
create table category
(
   category_id          int not null identity(1,1),
   level_one            varchar(30) not null,
   level_two            varchar(30) not null,
   is_valid             bit not null default 1,
   constraint pk_ctg_id primary key (category_id)
);


/*==============================================================*/
/* Table: receiver                                              */
/*==============================================================*/
create table receiver
(
   receiver_id          int not null identity(1,1),
   user_id              int not null,
   name                 varchar(30) not null,
   address              varchar(150) not null,
   phone                char(11) not null,
   used_times           int not null default 0,
   is_valid             bit not null default 1,
   constraint pk_receiver_id primary key (receiver_id),

   constraint fk_manage_receiver foreign key (user_id) references user_inf (user_id)
);
create index idx_receiver_userId ON dbo.receiver (user_id);

/*==============================================================*/
/* Table: favorite_shops                                          */
/*==============================================================*/
create table favorite_shops
(
   id                    bigint not null identity(1,1),
   shop_id               int not null,
   user_id               int not null,
   is_valid              bit not null default 1,
   
   constraint pk_favorite_shops_id primary key (id),
   constraint fk_favorite_shops_user foreign key (user_id) references user_inf (user_id),
   constraint fk_favorite_shops foreign key (shop_id) references shop (shop_id)
);
create index idx_favorite_shops_userId ON dbo.favorite_shops (user_id);

/*==============================================================*/
/* Table: favorite_goods                                         */
/*==============================================================*/
create table favorite_goods
(
   id                    bigint not null identity(1,1),
   goods_id              int not null,
   user_id               int not null,
   is_valid              bit not null default 1,

   constraint pk_favorite_goods_id primary key (id),
   constraint fk_favorite_goods_user foreign key (user_id) references user_inf (user_id),
   constraint fk_favorite_goods foreign key (goods_id) references goods (goods_id)
);
create index idx_favorite_goods_userId ON dbo.favorite_goods (user_id);

/*==============================================================*/
/* Table: shopping_cart                                           */
/*==============================================================*/
create table shopping_cart
(
   id                   bigint not null identity(1,1),
   user_id              int not null,
   attribute_id         int not null,
   /* Ϊ��֤Ч�����ӵ� goods_id ���� */
   goods_id             int not null,
   goods_num            int not null default 1,
   is_valid             bit not null default 1,

   constraint pk_shopping_cart_id primary key (id),
   constraint fk_shopping_cart_user foreign key (user_id) references user_inf (user_id),
   constraint fk_shopping_cart_attr foreign key (attribute_id) references goods_attribute (attribute_id),
   constraint chk_shopping_cart_goods_num check(goods_num >= 0)
);
create index idx_shopping_cart_userId ON dbo.shopping_cart (user_id);