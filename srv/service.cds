using { my.employeerequest as db } from '../db/schema';

service EmployeeService @(path: '/employee', requires: 'authenticated-user') {

  entity Employees as projection on db.Employee;

  @odata.draft.enabled
  entity Requests as projection on db.Request {
    *,
    // Transient UI-only field; value derived from Status in an after-READ handler
    virtual null as Criticality : Integer
  } actions {

    @(requires: 'Manager')
    action approve();

    @(requires: 'Manager')
    action decline();

  };

  entity Approvals as projection on db.Approval;

  // Value-help source for the Type dropdown
  @readonly
  entity RequestTypes as projection on db.RequestTypes;

}
