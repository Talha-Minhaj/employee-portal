using { my.employeerequest as db } from '../db/schema';

service EmployeeService @(path: '/employee') {

  entity Employees as projection on db.Employee;

  entity Requests as projection on db.Request actions {
    action approve();
    action decline();
  };

  entity Approvals as projection on db.Approval;

}
