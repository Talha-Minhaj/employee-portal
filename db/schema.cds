namespace my.employeerequest;

entity Employee {
  key EmployeeID : String;
  Name       : String;
  Email      : String;
  Role       : String; // 'Employee' or 'Manager'
  requests   : Association to many Request on requests.Employee = $self;
}

entity Request {
  key RequestID : UUID;
  Employee      : Association to Employee;
  Type          : String; // 'Leave', 'Expense', 'Travel'
  Description   : String;
  StartDate     : Date;
  EndDate       : Date;
  Amount        : Decimal(9,2);
  Status        : String default 'Pending'; // 'Pending', 'Approved', 'Rejected'
  approvals     : Association to many Approval on approvals.Request = $self;
}

entity Approval {
  key ApprovalID : UUID;
  Request        : Association to Request;
  ManagerID      : String;
  Decision       : String; // 'Approved', 'Rejected'
  Comment        : String;
  Timestamp      : Timestamp;
}

// Code list backing the fixed-value dropdown for Request.Type
entity RequestTypes {
  key code : String(20);
      name : String(60);
}