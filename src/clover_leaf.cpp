/*
 Crown Copyright 2012 AWE.

 This file is part of CloverLeaf.

 CloverLeaf is free software: you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the
 Free Software Foundation, either version 3 of the License, or (at your option)
 any later version.

 CloverLeaf is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 details.

 You should have received a copy of the GNU General Public License along with
 CloverLeaf. If not, see http://www.gnu.org/licenses/.
 */

//  @brief CloverLeaf top level program: Invokes the main cycle
//  @author Wayne Gaudin
//  @details CloverLeaf in a proxy-app that solves the compressible Euler
//  Equations using an explicit finite volume method on a Cartesian grid.
//  The grid is staggered with internal energy, density and pressure at cell
//  centres and velocities on cell vertices.
//
//  A second order predictor-corrector method is used to advance the solution
//  in time during the Lagrangian phase. A second order advective remap is then
//  carried out to return the mesh to an orthogonal state.
//
//  NOTE: that the proxy-app uses uniformly spaced mesh. The actual method will
//  work on a mesh with varying spacing to keep it relevant to it's parent code.
//  For this reason, optimisations should only be carried out on the software
//  that do not change the underlying numerical method. For example, the
//  volume, though constant for all cells, should remain array and not be
//  converted to a scalar.

#include <mpi.h>

// #include <Kokkos_Core.hpp>

#include <iostream>

#include "comms.h"
#include "definitions.h"
#include "hydro.h"
#include "initialise.h"
#include "version.h"
#include <chrono>
// Output file handler
std::ostream g_out(nullptr);

int main(int argc, char* argv[]) {
  // Initialise MPI first
  MPI_Init(&argc, &argv);
  // Obtain info on nodes and process id
  int comm_rank = -1;
  MPI_Comm_rank(MPI_COMM_WORLD, &comm_rank);

  MPI_Comm local_comm;
  MPI_Comm_split_type(MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, comm_rank,
                      MPI_INFO_NULL, &local_comm);

  int local_comm_rank = -1;
  MPI_Comm_rank(local_comm, &local_comm_rank);
  char node_name[MPI_MAX_PROCESSOR_NAME];
  int node_name_len = 0;
  MPI_Get_processor_name(node_name, &node_name_len);


  // Initialise Kokkos
  //	Kokkos::initialize();

  // Initialise communications
  struct parallel_ parallel;

  if (parallel.boss) {
	#ifdef CLOVER_LEAF_PRINT
    std::cout << std::endl
              << "Clover Version " << g_version << std::endl
              << "Kokkos Version" << std::endl
              << "Task Count " << parallel.max_task << std::endl
              << std::endl;
  #endif
  }
  auto start = std::chrono::high_resolution_clock::now();

  std::unique_ptr<global_variables> config =
      initialise(parallel, std::vector<std::string>(argv + 1, argv + argc));
  auto end = std::chrono::high_resolution_clock::now();
  auto initialise_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start); 
  
  
  std::cerr << "Node name: " << node_name << ", rank: " << comm_rank
            << ", local_rank: " << local_comm_rank << ", initialise_time [ms]: " << initialise_time.count() <<std::endl;
  
  // std::cout << "Launching hydro" << std::endl;
  start = std::chrono::high_resolution_clock::now();
  hydro(*config, parallel);
  
  // Finilise programming models
  //	Kokkos::finalize();
  config->queue.wait_and_throw();

  end = std::chrono::high_resolution_clock::now();
  auto hydro_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start); 
  
  std::cerr << "Node name: " << node_name << ", rank: " << comm_rank
            << ", local_rank: " << local_comm_rank << ", hydro_time [ms]: " << hydro_time.count() <<std::endl;
  if (parallel.boss)
    printf("\n");
  // clover_barrier();

#ifdef SYNERGY_DEVICE_PROFILING
  auto& q = config->queue;
  std::cerr << "Node name: " << node_name << ", rank: " << comm_rank
            << ", local_rank: " << local_comm_rank
            << ", device_energy_consumption [J]: "
            << q.device_energy_consumption() << std::endl;
#endif
  MPI_Finalize();

  return EXIT_SUCCESS;
}
