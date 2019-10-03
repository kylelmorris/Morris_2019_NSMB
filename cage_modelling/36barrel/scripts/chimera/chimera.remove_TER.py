#http://www.cgl.ucsf.edu/pipermail/chimera-users/2012-June/007660.html

# Force chimera to remove TER cards from all currently opened models
from chimera import Molecule, openModels, PDBio
for m in openModels.list(modelTypes=[Molecule]):
	for r in m.residues:
		r.isHet = False
		PDBio.addStandardResidue(r.type)