# Dashboard Narrative — Serving the Construction Business

This note is the plain-text companion to `Dashboard_Design_Document.docx`, kept here so the
business rationale is readable directly on GitHub without opening Word.

## Workflow efficiency

Before this dashboard, answering "which project is over budget and why" meant opening separate
cost reports, schedule trackers, and resource sheets. The three-page structure collapses that
into one flow: Page 1 (Executive Overview) identifies the problem project in seconds,
drill-through takes the user straight to Page 2's (Cost & Schedule Performance) root-cause view,
and the WBS task table pinpoints the exact task — a workflow that used to take three files and a
spreadsheet now takes three clicks.

## Resource management

The Resource Management page (Page 3) turns a reactive process — "we noticed the crew was
overbooked after the delay happened" — into a proactive one. The utilization heatmap and the
over-allocation KPI card are designed to be checked weekly by a resource planner, surfacing an
over-100%-utilization crew before it causes a schedule slip, not after.

## Project performance and predictive insight

CPI and SPI give a construction stakeholder industry-standard performance language rather than
ad-hoc percentages, and the EAC (Estimate at Completion) / Forecasted Completion Date cards
convert that historical performance into a forward-looking number — directly addressing the
brief's requirement for a predictive-completion view, and giving a project manager a number to
negotiate against (with a client or head office) rather than just a status update.

## Serving two audiences from one report

The page order is deliberately audience-aware: Page 1 is built for a 30-second executive glance,
while Pages 2 and 3 are built for the 20-minute operational review a project or resource manager
would do. Because both audiences share the same underlying star-schema model (see Task 3) and
the same colour language (blue = plan/budget, orange = actual/attention, red = unfavourable
variance, green = favourable), there is no second report to maintain and no risk of the two
audiences working from different numbers.

## Full detail

See `Dashboard_Design_Document.docx` for the complete conceptualization table, page-by-page
storyboard, interactivity plan, and visual-component specification.
