add_matlab_test(NAME examples/grasping/forceClosure/test/testFixedContactsSearchQ1 REQUIRES lcm libbot mosek spotless COMMAND testFixedContactsSearchQ1)
add_matlab_test(NAME examples/grasping/forceClosure/test/testForceClosureContactsFixedFaces REQUIRES lcm libbot mosek spotless COMMAND testForceClosureContactsFixedFaces)
add_matlab_test(NAME examples/grasping/forceClosure/test/testSynthesizeGrasp REQUIRES lcm libbot mosek spotless COMMAND testSynthesizeGrasp)
