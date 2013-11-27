String INPUT_RESPONSE = "INPUT_RESPONSE";

class InputResponse extends Component {

	ArrayList<InputResponseFunction> responses;

	InputResponse() {
		super(INPUT_RESPONSE);
		this.responses = new ArrayList<InputResponseFunction>();
	}

	InputResponse addInputResponseFunction(InputResponseFunction f) {
		this.responses.add(f);
		return this;
	}

	InputResponse reset() {
		this.responses = new ArrayList<InputResponseFunction>();
  		return this;
	}

}
