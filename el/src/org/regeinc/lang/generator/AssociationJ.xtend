package org.regeinc.lang.generator

import org.regeinc.lang.el.Association
import org.regeinc.lang.el.Entity
import org.regeinc.lang.el.SpecificTypeRef

class AssociationJ {
	private new(){		
	}
	static AssociationJ associationJ
	def static AssociationJ instance(){
		if(associationJ==null)
			associationJ = new AssociationJ()
		return associationJ
	}
	
	def compile(Association association)'''
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»«association.specificTypeRef.typeRef.type.name» «association.specificTypeRef.typeRef.name»;
		«getter(association)»
		«setter(association)»
		«builder(association)»
	'''

	def getter(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»«association.specificTypeRef.typeRef.type.name» get«association.specificTypeRef.typeRef.name.toFirstUpper»(){
			return this.«association.specificTypeRef.typeRef.name»;
		}
	'''

	def setter(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»void set«association.specificTypeRef.typeRef.name.toFirstUpper»(«association.specificTypeRef.typeRef.type.name» «association.specificTypeRef.typeRef.name»){
			«IF association.specificTypeRef.typeRef.NOTNULL»«compileNotNullPrefix(association.specificTypeRef)»«ENDIF»
			«IF association.specificTypeRef.orTypePrefix!=null»«new SpecificTypeRefJ(association.specificTypeRef.typeRef.name).applyConstraint(association.specificTypeRef.orTypePrefix)»«ENDIF»
			«IF association.constraint!=null»«ConditionJ::instance.compile(association.constraint.orCondition)»«ENDIF»
			this.«association.specificTypeRef.typeRef.name» = «association.specificTypeRef.typeRef.name»;
		}
	'''

	def builder(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF»«(association.eContainer as Entity).name» with«association.specificTypeRef.typeRef.name.toFirstUpper»(«association.specificTypeRef.typeRef.type.name» «association.specificTypeRef.typeRef.name»){
			«IF association.specificTypeRef.typeRef.NOTNULL»«compileNotNullPrefix(association.specificTypeRef)»«ENDIF»
			«IF association.specificTypeRef.orTypePrefix!=null»«»«ENDIF»
			«IF association.constraint!=null»«»«ENDIF»
			this.«association.specificTypeRef.typeRef.name» = «association.specificTypeRef.typeRef.name»;
			return this;
		}'''

	def compileNotNullPrefix(SpecificTypeRef specificTypeRef)'''
		
		if(«specificTypeRef.typeRef.name» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «specificTypeRef.typeRef.name»");
		}
	'''	
}