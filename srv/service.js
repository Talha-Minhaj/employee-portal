const cds = require('@sap/cds')

/**
 * Implementation for EmployeeService (see srv/service.cds).
 * CAP auto-loads this file because its name matches the .cds model file.
 */
module.exports = cds.service.impl(function () {
  const { Requests } = this.entities

  // Helper: pull the RequestID key out of req.params (works for bound
  // actions and for UPDATE, where the key comes from the URL, not the body).
  const keyOf = (req) => {
    const last = req.params?.[req.params.length - 1]
    return last && typeof last === 'object' ? last.RequestID : last
  }

  // ---------------------------------------------------------------------------
  // BEFORE CREATE (Request): validation + force default status
  // ---------------------------------------------------------------------------
  this.before('CREATE', Requests, (req) => {
    const r = req.data

    // 1) StartDate must not be in the past. CAP Date values are 'YYYY-MM-DD'
    //    strings, which compare correctly lexicographically.
    const today = new Date().toISOString().slice(0, 10)
    if (r.StartDate && r.StartDate < today) {
      req.error(400, `StartDate (${r.StartDate}) must not be in the past.`, 'StartDate')
    }

    // 2) Expense requests must have a strictly positive Amount.
    if (r.Type === 'Expense' && !(Number(r.Amount) > 0)) {
      req.error(400, `Amount must be greater than 0 for Expense requests.`, 'Amount')
    }

    // 3) Status is always forced to 'Pending' on create, regardless of input.
    r.Status = 'Pending'
  })

  // ---------------------------------------------------------------------------
  // BEFORE UPDATE (Request): block edits once a decision has been made
  // ---------------------------------------------------------------------------
  this.before('UPDATE', Requests, async (req) => {
    const id = keyOf(req)
    const existing = await SELECT.one.from(Requests).columns('Status').where({ RequestID: id })

    if (!existing) return // let CAP raise the standard 404

    if (existing.Status === 'Approved' || existing.Status === 'Rejected') {
      req.error(409, `Request ${id} is already ${existing.Status} and can no longer be modified.`)
    }
  })

  // ---------------------------------------------------------------------------
  // ON approve / reject (bound actions): set the decision status
  // ---------------------------------------------------------------------------
  this.on('approve', Requests, (req) => decide(req, 'Approved'))
  this.on('decline', Requests, (req) => decide(req, 'Rejected'))

  async function decide(req, status) {
    const id = keyOf(req)

    const found = await SELECT.one.from(Requests).columns('Status').where({ RequestID: id })
    if (!found) return req.error(404, `Request ${id} not found.`)

    await UPDATE(Requests).set({ Status: status }).where({ RequestID: id })
    return SELECT.one.from(Requests).where({ RequestID: id })
  }
})
