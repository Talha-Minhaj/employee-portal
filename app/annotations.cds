using EmployeeService from '../srv/service';

annotate EmployeeService.Requests with @(

  // ── Header: title of the Object Page + object type names ──────────────────
  UI.HeaderInfo: {
    $Type          : 'UI.HeaderInfoType',
    TypeName       : 'Request',
    TypeNamePlural : 'Requests',
    Title          : { $Type: 'UI.DataField', Value: Description },
    Description    : { $Type: 'UI.DataField', Value: Type }
  },

  // ── List Report table: columns + toolbar action buttons ───────────────────
  UI.LineItem: [
    { $Type: 'UI.DataFieldForAction', Action: 'EmployeeService.approve', Label: 'Approve' },
    { $Type: 'UI.DataFieldForAction', Action: 'EmployeeService.decline', Label: 'Decline' },
    { $Type: 'UI.DataField', Value: RequestID,   Label: 'Request ID',  ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: Type,        Label: 'Type',        ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: Description, Label: 'Description',  ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: StartDate,   Label: 'Start Date',  ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: Amount,      Label: 'Amount',      ![@UI.Importance]: #High },
    { $Type: 'UI.DataField', Value: Status,      Label: 'Status',      ![@UI.Importance]: #High }
  ],

  // ── Object Page header action buttons (from UI.Identification) ─────────────
  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'EmployeeService.approve', Label: 'Approve' },
    { $Type: 'UI.DataFieldForAction', Action: 'EmployeeService.decline', Label: 'Decline' }
  ],

  // ── Object Page body: one field group with the full request detail ─────────
  UI.FieldGroup #RequestDetails: {
    $Type : 'UI.FieldGroupType',
    Data  : [
      { $Type: 'UI.DataField', Value: RequestID,           Label: 'Request ID' },
      { $Type: 'UI.DataField', Value: Employee_EmployeeID, Label: 'Employee' },
      { $Type: 'UI.DataField', Value: Type,                Label: 'Type' },
      { $Type: 'UI.DataField', Value: Description,         Label: 'Description' },
      { $Type: 'UI.DataField', Value: StartDate,           Label: 'Start Date' },
      { $Type: 'UI.DataField', Value: EndDate,             Label: 'End Date' },
      { $Type: 'UI.DataField', Value: Amount,              Label: 'Amount' },
      { $Type: 'UI.DataField', Value: Status,              Label: 'Status' }
    ]
  },

  UI.Facets: [
    {
      $Type  : 'UI.ReferenceFacet',
      ID     : 'RequestDetailsFacet',
      Label  : 'Request Details',
      Target : '@UI.FieldGroup#RequestDetails'
    }
  ]
);
