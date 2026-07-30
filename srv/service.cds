using { my.employeerequest as db } from '../db/schema';

service EmployeeService @(path: '/employee', requires: 'authenticated-user') {

  entity Employees as projection on db.Employee;

  entity Requests as projection on db.Request actions {

    @(requires: 'Manager')
    action approve();

    @(requires: 'Manager')
    action decline();

  };

  entity Approvals as projection on db.Approval;

}
