checklists["parking"] = {	title: 'PARKING',
							items: [checklist_item.new( desc: 'APU BLEED',
									resp: 'ON',
									manual: 0,
									prop: '/controls/pressurization/apu/bleed-on',
									value: 1),
									
									checklist_item.new( desc: 'ENGINES',
									resp: 'OFF',
									manual: 0,
									prop: '/engines/engine[3]/running',
									value: 0),
									
									checklist_item.new( desc: 'SEAT BELTS',
									resp: 'OFF',
									manual: 0,
									prop: '/controls/signs/seatbelt',
									value: 0),
									
									checklist_item.new( desc: 'EXT LT',
									resp: 'AS RQRD',
									manual: 1),
									
									checklist_item.new( desc: 'FUEL PUMPS',
									resp: 'OFF',
									manual: 1),
									
									checklist_item.new( desc: 'PARK BRK AND CHOCKS',
									resp: 'AS RQRD',
									manual: 1)]};
