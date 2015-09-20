/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

public class EntityComponents {
    private let entityFactory = EntityFactory()
    private var componentsByEntityAndKind: [Entity: [Kind : Component]] = [:]
    private var entitiesByKind: [Kind : [Entity]] = [:]
    
    public func createEntity() -> Entity {
        let entity = entityFactory.createEntity()
        componentsByEntityAndKind[entity] = [:]
        return entity
    }
    
    public func getEntitiesWithComponentType<ComponentType : Component>(componentType: ComponentType.Type) -> [Entity] {
        let kind = ComponentType.kind
        return entitiesByKind[kind] ?? []
    }
    
    public func getEntitiesWithComponentTypes(componentTypes: [Component.Type]) -> [Entity] {
        var entitySet = Set<Entity>()
        
        for componentType in componentTypes {
            let kind = componentType.kind
            let entities = entitiesByKind[kind] ?? []
            
            if entities.count == 0 { return [] }
            
            if entitySet.count == 0 {
                entitySet.unionInPlace(entities)
            }
            else {
                entitySet.intersectInPlace(entities)
            }
        }
        
        return [Entity](entitySet)
    }
    
    public func addComponent<ComponentType : Component>(component: ComponentType, toEntity entity: Entity) {
        let kind = ComponentType.kind
        
        var componentsByKind = componentsByEntityAndKind[entity]!
        precondition(componentsByKind[kind] == nil)
        componentsByKind[kind] = component
        componentsByEntityAndKind[entity] = componentsByKind
        
        var entities = entitiesByKind[kind] ?? []
        entities.append(entity)
        entitiesByKind[kind] = entities
    }
    
    public func replaceComponent<ComponentType : Component>(component: ComponentType, forEntity entity: Entity) {
        let kind = ComponentType.kind
        
        var componentsByKind = componentsByEntityAndKind[entity]!
        precondition(componentsByKind[kind] != nil)
        componentsByKind[kind] = component
        componentsByEntityAndKind[entity] = componentsByKind
    }
    
    public func componentForEntity<ComponentType: Component>(entity: Entity, withComponentType componentType: ComponentType.Type) -> ComponentType? {
        guard let componentsByKind = componentsByEntityAndKind[entity] else { return nil }
        let kind = ComponentType.kind
        return componentsByKind[kind] as? ComponentType
    }
}
