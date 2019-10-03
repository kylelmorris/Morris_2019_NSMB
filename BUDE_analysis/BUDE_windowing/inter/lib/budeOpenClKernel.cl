/**
 * BUDE OpenCL kernel file
 **/

//#pragma OPENCL EXTENSION cl_intel_printf : enable

// SMALL KERNEL for fast testing no real work
//------------------------------------8<----------------------------------------
//typedef struct _atomBude {
//  float x, y, z;
//  float radius, hydro_potential, hardness, npolar_npolar_distance,
//      npolar_polar_distance, elec_potential;
//  char elec_type, name[3];
//} AtomBude;
//
//
//
//__kernel void bude_dock( __global AtomBude *receptor_molecule,
//    __global AtomBude *ligand_molecule, __global float *transforms,
//    __global float *energies_total, int ligandAtomsNumber,
//    int receptorAtomsNumber, int numTransforms) {
//
//printf("LigandAtoms %d - ReceptorAtoms %d - numTrasnform %d\n\n",ligandAtomsNumber, receptorAtomsNumber, numTransforms);
//
//  int i = get_global_id(0);
//
//  energies_total[i] = i * 2.99f;
//
//}
// END OF SMALL KERNEL
//------------------------------------8<----------------------------------------

#define MAX_NATLIG 3000

// Numeric constants
#define ZERO 0.0f
#define HALF 0.5f
#define ONE 1.0f
#define TWO 2.0f
#define CNSTNT 45.0f

typedef struct _atom {
  float x, y, z;
  float radius, hphb, hard, nndst, npdst, elsc;
  //int hbtype_name;  // WAS:  char  hbtype, name[3];
  char hbtype;
} Atom;

//void printMolecule(const unsigned atomsNumber, __global Atom *molecule) {
//
//  for (int i = 0; i < atomsNumber; i++)
//  {
//    printf("[%d] %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f %c\n",
//        i,
//        molecule[i].x,
//        molecule[i].y,
//        molecule[i].z,
//        molecule[i].radius,
//        molecule[i].hphb,
//        molecule[i].hard,
//        molecule[i].nndst,
//        molecule[i].npdst,
//        molecule[i].elsc,
//        molecule[i].hbtype
//    );
//  }
//  return;
//}
//
//
//void printTransforms(const unsigned transformNumber, __global float *transforms) {
//
//  //printf("What went wrong: %d\n", transformNumber);
//
//  unsigned index = 0;
//  
//  for (int i = 0; i < transformNumber; i++ )
//  {
//
//    printf("[%d] %4.4f %4.4f %4.4f %4.4f %4.4f %4.4f \n",
//        i,
//        transforms[index],
//        transforms[index+1],
//        transforms[index+2],
//        transforms[index+3],
//        transforms[index+4],
//        transforms[index+5]
//    );
//    index += 6;
//  }
//  return;
//}

__kernel void bude_dock(
    __global Atom *protein_molecule,
    __global Atom *ligand_molecule,
    __global float *transforms,
    __global float *etotals,
    const unsigned natlig, const unsigned natpro,
    const unsigned numTransforms)
{

  // Get unique ID for work item
  int ix = get_global_id(0);

  // Ensure work is valid
  if (ix >= numTransforms)
  {
    return;
  }

//  if (ix == 0)
//  {
//    //printf("ligandAtoms: %d - receptorAtoms: %d - transforms: %d\n", natlig, natpro, numTransforms);
//    //printMolecule(natpro, ligand_molecule);
//    //printMolecule(natpro, protein_molecule);
//    //printTransforms(numTransforms, transforms);
//  }

  // Buffer for transformed ligand
  // TODO: Change to float3 when OpenCL 1.1 is fully supported.
  float4 lpos[MAX_NATLIG];

  // Compute transformation matrix to private memory
  float cx;
  float xa = transforms[(ix*6)];
  float sx = sincos(xa,&cx);

  float cy;
  float ya = transforms[(ix*6)+1];
  float sy = sincos(ya, &cy);

  float cz;
  float za = transforms[(ix*6)+2];
  float sz = sincos(za, &cz);

  float4 transform[3];
  transform[0].x = cy*cz;
  transform[0].y = sx*sy*cz - cx*sz;
  transform[0].z = cx*sy*cz + sx*sz;
  transform[0].w = transforms[(ix*6)+3];
  transform[1].x = cy*sz;
  transform[1].y = sx*sy*sz + cx*cz;
  transform[1].z = cx*sy*sz - sx*cz;
  transform[1].w = transforms[(ix*6)+4];
  transform[2].x = -sy;
  transform[2].y = sx*cy;
  transform[2].z = cx*cy;
  transform[2].w = transforms[(ix*6)+5];

  // Transform ligand positions
  for (int il = 0; il < natlig; il++)
  {
    float4 linitpos;
    linitpos.x = ligand_molecule[il].x;
    linitpos.y = ligand_molecule[il].y;
    linitpos.z = ligand_molecule[il].z;
    linitpos.w = 1;

    lpos[il].x = dot(linitpos, transform[0]);
    lpos[il].y = dot(linitpos, transform[1]);
    lpos[il].z = dot(linitpos, transform[2]);
  }

  // Initialise accumulator
  float etot = ZERO;

  // Loop over all the protein balls
  for (int ip = 0; ip < natpro; ip++)
  {
    Atom protein_atom = protein_molecule[ip];

    // Take a copy of this protein atom into local variables
    float p_x = protein_atom.x;
    float p_y = protein_atom.y;
    float p_z = protein_atom.z;
    float p_radius = protein_atom.radius;
    float p_hphb = protein_atom.hphb;
    float p_hard = protein_atom.hard;
    float p_nndst = protein_atom.nndst;
    float p_npdst = protein_atom.npdst;
    float p_elsc = protein_atom.elsc;
    char p_hbtype = protein_atom.hbtype;
    bool p_hphb_nzero = (p_hphb != ZERO);
    bool p_hphb_ltzero = (p_hphb < ZERO);

    //---------Calculate the distance between the ball centres
    for (int il = 0; il < natlig; il++)
    {
      /** TODO  >>>>>vectorise me<<<<<<<< would help SIMD devices **/
      float x = lpos[il].x - p_x;
      float y = lpos[il].y - p_y;
      float z = lpos[il].z - p_z;
      float distij = native_sqrt(x*x + y*y + z*z);

      //------Calculate the sum of the sphere radii
      float radij = p_radius + ligand_molecule[il].radius;
      float distbb = distij - radij;
      bool zone1 = (distbb < ZERO);

      //-----Step 1 : Calculate steric energy for when distance is less than the sum of the radii

      // note radij doesnt change with translation or rotamer - so could calc once and save?
      // (and indeed merge with p_hard*l_hard

      if (zone1)
      {
        etot += (ONE - native_divide(distij, radij)) * (p_hard + ligand_molecule[il].hard);
      }

      //------Step 2 : Calculate formal and dipole charge interactions.
      if (p_elsc != ZERO)
      {
        //----------First set the constant for the coulombic equn, for formal charge or dipole interaction
        float elcdst1 = HALF, elcdst = TWO;
        // note I could do the 'E' test as an elseif ?
        if (p_hbtype == 'F')
        {
          if (ligand_molecule[il].hbtype == 'F')
          {
            elcdst1 = 0.25f; elcdst = 4.0f;
          }
        }

        //----------Assign an optimal interaction for non-overlapping spheres, to spheres within overlapping distance
        //----------Then linearly decrease the interaction as the spheres move further apart
        if (distbb < elcdst)// if an interaction
        {
          //float chrg_e = cnstnt * (ligand_atom->elsc * p_elsc);
          // The upper line was uncommented and the line below was commented as suggested by R. Sessions
          // the commented action was reverted. Crazy results
          float chrg_e = ligand_molecule[il].elsc * p_elsc;
          if (!zone1)
          {
            // in outer zone so scale back
            chrg_e *= (ONE - distbb*elcdst1);
          }

          // note that the embedded dataset has no 'E's
          // RBS: OR not AND
          if (p_hbtype == 'E' || ligand_molecule[il].hbtype == 'E')
          {
            // RBS: not < 0 but > 0
            if (chrg_e > ZERO) chrg_e = -chrg_e;
          }
          etot += chrg_e*CNSTNT;
        }  // if an interaction

      }

      //-----Step 3 : Calculate the two cases for Nonpolar-Polar repulsive interactions:
      //-----First is where the ligand is Nonpolar, and the protein is Polar.
      //-----Followed by a linearly reducing interaction over an additional npdist Angstroms.
      // in 2.24 135 cycles
      // This section doesn't often get invoked as only a value if both atoms are nonzero
      float distdslv;// desolvation distance
      bool p_action = 0;
      float p_hphb1,l_hphb;
      if (p_hphb_nzero)// mono if
      {
        l_hphb = ligand_molecule[il].hphb;
        p_hphb1 = p_hphb;
        if (p_hphb_ltzero)
        {
          if (l_hphb < ZERO)
          {
            distdslv = p_nndst;
            p_action=1;
          }
          else if (l_hphb > ZERO)
          {
            distdslv = ligand_molecule[il].npdst;
            p_hphb1 = -p_hphb1;
            p_action=1;
          }
        }
        else
        { // P must be +ve
          if (l_hphb < ZERO)
          {
            //if (p_hphb > zero) { // already done this test in mono
            distdslv = p_npdst;
            l_hphb = -l_hphb;
            p_action=1;
          }
        }

        if (p_action==1)
        {
          if (distbb < distdslv) // if an interaction
          {
            //dslv_e = half*(p_hphb1+l_hphb1);
            float dslv_e = p_hphb1 + l_hphb;
            if (!zone1)
            {
              // if in outer zone, scale back
              dslv_e *= (ONE - native_divide(distbb, distdslv));
            }
            etot += dslv_e;
          }
        }
      } // skip if p_hphb is zero
      /**} // skip to point if distij>10 **/
    } // loop ligand atoms
  } // loop over protein molecule

  //-----Add this atoms steric, desolvation, and charge energies to the cumulative total 'etot'.
  // etotals[ix] = 999.9999;
  etotals[ix] = etot*HALF;

}
