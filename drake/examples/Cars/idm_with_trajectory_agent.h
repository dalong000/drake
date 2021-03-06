#pragma once

#include "drake/examples/Cars/gen/idm_with_trajectory_agent_state.h"
#include "drake/systems/framework/leaf_system.h"

namespace drake {

/// IdmWithTrajectoryAgent -- model a car using IDM[1], following an idealized
/// agent car that is decelerating. The implementation here follows closely the
/// idm_with_trajectory_agent.drh dReach model, authored by Jon DeCastro.
///
/// [1] IDM: Intelligent Driver Model:
///    https://en.wikipedia.org/wiki/Intelligent_driver_model
///
/// This class uses Drake's `-inl.h` pattern.  When seeing linker errors from
/// this class, please refer to http://drake.mit.edu/cxx_inl.html.
///
/// Instantiated templates for the following kinds of T's are provided:
/// - double
/// - TarlorVarXd
///
/// They are already available to link against in libdrakeCars.
template <typename T>
class IdmWithTrajectoryAgent : public systems::LeafSystem<T> {
 public:
  IdmWithTrajectoryAgent();
  ~IdmWithTrajectoryAgent() override;

  // System<T> overrides
  void EvalOutput(const systems::ContextBase<T>& context,
                  systems::SystemOutput<T>* output) const override;
  void EvalTimeDerivatives(
      const systems::ContextBase<T>& context,
      systems::ContinuousState<T>* derivatives) const override;

 protected:
  // LeafSystem<T> overrides
  std::unique_ptr<systems::ContinuousState<T>> AllocateContinuousState()
      const override;
  std::unique_ptr<systems::VectorBase<T>> AllocateOutputVector(
      const systems::SystemPortDescriptor<T>& descriptor) const override;
};

}  // namespace drake
