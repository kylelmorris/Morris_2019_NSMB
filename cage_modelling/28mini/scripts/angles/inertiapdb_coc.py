# -----------------------------------------------------------------------------
# Compute inertia tensor principle axes for molecule.
#
def inertia_ellipsoid(m):

  atoms = m.atoms
  n = len(atoms)
  from _multiscale import get_atom_coordinates
  xyz = get_atom_coordinates(atoms)
  anum = [a.element.number for a in atoms]
  from numpy import array, dot, outer, argsort, linalg
  wxyz = array(anum).reshape((n,1)) * xyz
  mass = sum(anum)

  c = wxyz.sum(axis = 0) / mass    # Center of mass
  v33 = dot(xyz.transpose(), wxyz) / mass - outer(c,c)
  eval, evect = linalg.eigh(v33)

  # Sort by eigenvalue size.
  order = argsort(eval)
  seval = eval[order]
  sevect = evect[:,order]

  return sevect, seval, c

# -----------------------------------------------------------------------------
#
def ellipsoid_surface(center, axes, lengths, color = (.7,.7,.7,1)):

  from Icosahedron import icosahedron_triangulation
  varray, tarray = icosahedron_triangulation(subdivision_levels = 3,
                                             sphere_factor = 1.0)
  
  #print(varray)
  from numpy import dot, multiply
  es = dot(varray, axes)
  print("This is my ES: ", es)
  ee = multiply(es, lengths)
  ev = dot(ee, axes.transpose())
  ev += center

  import _surface
  sm = _surface.SurfaceModel()
  sm.addPiece(ev, tarray, color)
  return sm

# -----------------------------------------------------------------------------
#
def show_ellipsoid(axes, d2, center, model):

  from math import sqrt
  d = [sqrt(e) for e in d2]
  sm = ellipsoid_surface(center, axes, d)
  sm.name = 'inertia ellipsoid for %s' % m.name
  from chimera import openModels as om
  om.add([sm], sameAs = model)

# -----------------------------------------------------------------------------
#
def print_axes(axes, d2, m, center):

  from math import sqrt
  paxes = ['\tv%d = %7.4f %7.4f %7.4f   d%d = %7.3f' %
           (a+1, axes[a][0], axes[a][1], axes[a][2], a+1, sqrt(d2[a]))
           for a in range(3)]
  from chimera.replyobj import info
  info('Inertia axes for %s\n%s\n' % (m.name, '\n'.join(paxes)))
  info('Centre of mass %7.4f %7.4f %7.4f\n ' % (center[0],center[1],center[2]) )
  from Accelerators.standard_accelerators import show_reply_log
  show_reply_log()

# -----------------------------------------------------------------------------
#
from chimera import openModels as om, Molecule
mlist = om.list(modelTypes = [Molecule])
for m in mlist:
  axes, d2, center = inertia_ellipsoid(m)
  print_axes(axes, d2, m, center)
  show_ellipsoid(axes, d2, center, m)
