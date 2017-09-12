# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


BasicAuth.create(id:1,name:'mad',password: 'mad')
Role.create(id:1,role: Role.ADMINISTRATOR,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:2,role: Role.NATIONAL_CFR_HEAD,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:3,role: Role.NATIONAL_EVENTS_HEAD,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:4,role: Role.NATIONAL_FINANCIAL_CONTROLLER,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:5,role: Role.CITY_PRESIDENT,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

Role.create(id:6,role: Role.CFR_FELLOW,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:7,role: Role.EVENTS_FELLOW,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:8,role: Role.CITY_FINANCIAL_CONTROLLER,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:9,role: Role.CFR_POC,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
Role.create(id:10,role: Role.VOLUNTEER,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')


RoleReportTo.create(id:1,user_role_id:2,manager_role_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:2,user_role_id:3,manager_role_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:3,user_role_id:4,manager_role_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:4,user_role_id:5,manager_role_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

RoleReportTo.create(id:5,user_role_id:6,manager_role_id:2,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:6,user_role_id:6,manager_role_id:5,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:7,user_role_id:7,manager_role_id:5,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:8,user_role_id:7,manager_role_id:8,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:9,user_role_id:7,manager_role_id:3,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:10,user_role_id:8,manager_role_id:4,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

RoleReportTo.create(id:11,user_role_id:9,manager_role_id:6,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:12,user_role_id:9,manager_role_id:8,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

RoleReportTo.create(id:13,user_role_id:10,manager_role_id:9,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
RoleReportTo.create(id:15,user_role_id:10,manager_role_id:7,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

State.create(id:1,name: 'Karnatak',created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
City.create(id:1,name: 'Bengaluru',state_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')

User.create(id: 1, email: 'admin@makeadiff.org',encrypted_password: '$2a$10$cC6wst3NZYOW/2oIRXXyHeuzAZ4MzL/.ANisnytutUSe3XykN.KLe' ,reset_password_token: '12331', reset_password_sent_at: '12/12/2013' , remember_created_at: '12/12/2013' ,sign_in_count: 12,current_sign_in_at: '12/12/2013',last_sign_in_at: '12/12/2013',first_name: "Admin" , last_name:"MakeaDiff",phone_no:1234567890,city_id: 1)
UserRoleMap.create(id:1,role_id:1,user_id:1,created_at:'2013-08-05 11:06:23',updated_at:'2013-08-05 11:06:23')
CfrProduct.create(name:'',is_other_product:0)