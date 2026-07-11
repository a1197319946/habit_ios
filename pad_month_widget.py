import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

old_layout = """                                }
                            }
                        }
                    }
                }
            }
        }"""
new_layout = """                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 12)"""

code = code.replace(old_layout, new_layout)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
