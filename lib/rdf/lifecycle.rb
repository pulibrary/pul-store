# This file generated automatically using vocab-fetch from http://vocab.org/lifecycle/schema-20080603.rdf
require 'rdf'
module RDF
  class LIFECYCLE < StrictVocabulary("http://purl.org/vocab/lifecycle/schema#")

    # Class definitions
    property :Action, :label => 'Action', :comment =>
      %(Represents an instance of a task taking place against a given
        resource)
    property :Lifecycle, :label => 'Lifecycle', :comment =>
      %(A lifecycle is a series of states connected by allowable
        transitions. It may be used to describe the lifecycle of
        business objects or equally the lifecycle of a butterfly.)
    property :State, :label => 'State', :comment =>
      %(A state describes one possible state that a resource can be in
        at a given time. Resources may be in one state in a given
        lifecycle at any given time, states are considered mutually
        exclusive within a lifecycle.)
    property :Task, :label => 'Task', :comment =>
      %(Represents a task in a workflow)
    property :Task, :label => 'Task', :comment =>
      %(Represents a task in a workflow)
    property :TaskGroup, :label => 'Task Group', :comment =>
      %(Represents a collection of tasks grouped together for
        convenience)
    property :TaskGroup, :label => 'Task Group', :comment =>
      %(Represents a collection of tasks grouped together for
        convenience)
    property :Transition, :label => 'Transition', :comment =>
      %(A transition describes the way in which a resource moves from
        one state to another state and may also describe the tasks
        required to make that transition.)
    property :Transition, :label => 'Transition', :comment =>
      %(A transition describes the way in which a resource moves from
        one state to another state and may also describe the tasks
        required to make that transition.)

    # Property definitions
    property :completed, :label => 'completed', :comment =>
      %(This uses a boolean to represent if an action has been
        completed. This is a simple alternative to the taskProgress
        property.)
    property :mandatory, :label => 'mandatory', :comment =>
      %(Sepcifies if a task is mandatory or optional.)
    property :next, :label => 'next', :comment =>
      %(provides a simple ordering relationship to allow tasks to be
        ordered in user interfaces.)
    property :possibleState, :label => 'possible state', :comment =>
      %(The possible state property is used to identify the states
        that occur within a given lifecycle and are thus the possible
        states of a resource going through that lifecycle.)
    property :possibleTransition, :label => 'possible transition', :comment =>
      %(When in a state there may be many possible transitions.)
    property :resource, :label => 'resource', :comment =>
      %(The resource on which the action being taken. This is a
        resource that is being processed through a lifecycle.)
    property :resultingState, :label => 'resulting state', :comment =>
      %(Once a transition is completed the state of the resource
        should change to the state specified as the resulting state.)
    property :state, :label => 'state', :comment =>
      %(The state property relates any resource with the state that it
        is currently in.)
    property :stateOf, :label => 'state of', :comment =>
      %(The 'state of' property is the inverse of the state property,
        relating a state to all of the resources currently in that
        state.)
    property :task, :label => 'task', :comment =>
      %(A task related to this transition.)
    property :taskGroup, :label => 'task group', :comment =>
      %(A task group related to this transition.)
    property :taskProgress, :label => 'task progress', :comment =>
      %(The current progress on this task. Some resources are defined
        in this ontology for this, but you are free to define your
        own.)
  end
end
