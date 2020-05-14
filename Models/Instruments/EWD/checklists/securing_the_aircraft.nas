checklists["securing_the_aircraft"] = {
							title: 'SECURING THE AIRCRAFT',
							items:[ checklist_item.new( desc: 'ADIRS',
									resp: 'OFF',
									manual: 1),
									
									checklist_item.new( desc: 'OXYGEN',
									resp: 'OFF',
									manual: 1),
									
									checklist_item.new( desc: 'APU BLEED',
									resp: 'OFF',
									manual: 0,
									prop: '/controls/pressurization/apu/bleed-on',
									value: 0),
									
									checklist_item.new( desc: 'EMER EXIT LT',
									resp: 'OFF',
									manual: 0,
									prop: '/controls/lighting/emer-exit-lt',
									value: 0),
									
									checklist_item.new( desc: 'NO SMOKING',
									resp: 'OFF',
									manual: 0,
									prop: '/controls/signs/no-smoking',
									value: 0),
									
									checklist_item.new( desc: 'APU',
									resp: 'OFF',
									manual: 0,
									prop: '/engines/engine[4]/running',
									value: 0),
									
									checklist_item.new( desc: 'BAT',
									resp: 'OFF',
									manual: 0,
									prop: '/controls/electric/contact/batt_1',
									value: 0)
]};
