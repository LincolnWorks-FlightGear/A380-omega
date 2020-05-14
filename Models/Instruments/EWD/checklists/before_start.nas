checklists["before_start"] = {
								title: 'BEFORE START',
								items: [checklist_item.new(desc: 'COCKPIT PREP',
										resp: 'COMPLETED',
										manual: 1),
										
										checklist_item.new(desc: 'GEAR PINS AND COVERS',
										resp: 'REMOVED',
										manual: 1),

										checklist_item.new(desc: 'NO-SMOKING SIGN',
										resp: 'ON / AUTO',
										manual: 0,
										prop: '/controls/signs/no-smoking',
										value: 1),

										checklist_item.new(desc: 'SEATBELT SIGN',
										resp: 'ON / AUTO',
										manual: 0,
										prop: '/controls/signs/seatbelt',
										value: 1),

										checklist_item.new(desc: 'FUEL QUANTITY',
										resp: 'CHECKED',
										manual: 1),

										checklist_item.new(desc: 'T/O PERF DATA',
										resp: 'SET',
										manual: 1),

										checklist_item.new(desc: 'BARO REF',
										resp: 'SET (BOTH)',
										manual: 1),

										checklist_item.new(desc: 'WINDOWS/DOORS',
										resp: 'CLOSED',
										manual: 1),

										checklist_item.new(desc: 'BEACON',
										resp: 'ON',
										manual: 0,
										prop: '/controls/lighting/beacon',
										value: 1),

										checklist_item.new(desc: 'THR LEVERS',
										resp: 'IDLE',
										manual: 0,
										prop: '/controls/engines/engine/throttle',
										value: 0),

										checklist_item.new(desc: 'PARKING BRAKE',
										resp: 'AS RQRD',
										manual: 1)
]};
