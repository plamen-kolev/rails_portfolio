namespace :faker do
  desc "TODO"
  task init: :environment do

    Rake::Task['db:purge'].invoke
    Rake::Task['db:migrate'].invoke

    a = Article.new
    a.title = <<-HEREDOC
      Data classification using Neural Networks and Genetic Programming
HEREDOC
    a.body = <<-HEREDOC
<div id="content">
<div id="preamble">
<div class="sectionbody">
<div class="paragraph">
<p>Plamen Kolev</p>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_genetic_programming">Genetic Programming</h2>
<div class="sectionbody">
<div class="sect2">
<h3 id="_revised_justification">Revised justification</h3>
<div class="imageblock">
<div class="content">
<img src="/media/gpimages/gp.png" alt="Image taken from http://www.ra.cs.uni-tuebingen.de/software/JCell/images/docbook/gp.png">
</div>
</div>
<div class="paragraph">
<p>As the first biologically inspired machine learning algorithm, I decided to use Genetic Programming. Genetic Programming is suitable for classifying multiple classes. An Oxford journal about classifying microarray datasets talks about ways GP can be used to classify and diagnose particular types of cancer (Kun-Hong L. et al. 2008). An implementation of a Genetic Programming for classification works by applying divide and conquer strategies to the training data, splitting it into multiple sets of decision trees. The leaves of the trees represent different classes (Jeroen Eggermont et al. 2004).</p>
</div>
<div class="paragraph">
<p>In the original proposal, I make the case for using Genetic Algorithm with k-nearest neighbours, but later decided to not use it, as GP frameworks such as <strong>epochx</strong> contain all the necessary libraries and tuning strategies that will provide a better result with the ability to do more fine-grain tuning. It will also allow me to explore a more generic solution.</p>
</div>
<div class="paragraph">
<p>In genetic programming, each decision branch is formed by a mathematical expression (functions). For the dataset, I experimented with different 'syntax' functions. The findings are documented in the tuning section for this algorithm, but the most effective were the trigonometric ones.</p>
</div>
</div>
<div class="sect2">
<h3 id="_description_of_implementation">Description of implementation</h3>
<div class="paragraph">
<p>As mentioned above, I used the <strong>epochx</strong> library framework to bootstrap my implementation. I created a new source package called <strong>GP</strong>, which contains <code>GPClassifier.java</code>, <code>GPControl.java</code> and <code>GPWrapper.java</code>. The implementation of the <code>GPControl</code> class is very similar to the provided sample one, as its purpose is to test the actual implementation. Minor modifications were made to accommodate for the newly created data structures. Another modification is exposing the <code>generateSubSolution</code> to return <code>GPClassifier</code>, as this class is used in the main method to write performance and configuration statistics to a report file called <code>gpstats.csv</code>.</p>
</div>
<div class="paragraph">
<p>The <code>GPClassifier</code> class contains a genetic program instance that has learned on the training data and implements <code>classifyInstance</code> and <code>printClassifier</code>. Those methods are passed to the underlying genetic programming class <code>GPWrapper</code>, the class is acting as a middle man between the control and the genetic programming class.</p>
</div>
<div class="paragraph">
<p>The <code>GPWrapper</code> class contains all the necessary constructs and tunable variables for the <strong>epoch</strong> framework,which are described in the tuning section.</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">GPWrapper.java constructor</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">syntax.add(new SignumFunction());
syntax.add(new SineFunction());
syntax.add(new CosineFunction());
syntax.add(new ArcTangentFunction());
syntax.add(new AbsoluteFunction());

syntax.add(new AddFunction());
syntax.add(new DivisionProtectedFunction());
syntax.add(new SubtractFunction());
...
for (int i = 0; i &lt; Attributes.getNumAttributes(); i++) {
    syntax.add( variables[i] = new Variable("dim" + i, Double.class) );
}</code></pre>
</div>
</div>
<div class="paragraph">
<p>The constructor allows for an arbitrary attributes to be passed as the syntax, but the syntax functions are specially tuned for the given dataset, as trigonometric functions are suitable for classifying the circular representation of the data.</p>
</div>
<div class="paragraph">
<p>An auxiliary function called <code>parseData</code> is provided just to store the data in an internal array for later usage.<br>
This class also returns itself as an instance when <code>generateClassifier</code> is called. The method is responsible for setting the different tuning parameters and training the genetic program.</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">GPWrapper.java classifyInstance method</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">public int classifyInstance(Instance ins){
    GPCandidateProgram a = (GPCandidateProgram) this.getProgramSelector().getProgram();
    for (int i = 0; i &lt; Attributes.getNumAttributes(); i++) {
        this.variables[i].setValue(ins.getRealAttribute(i));
    }
    Double result = (Double) a.evaluate();
    return  (int) Math.round(result);
}</code></pre>
</div>
</div>
<div class="paragraph">
<p>The <code>classifyInstance</code> method is used after the GP is trained to determine the class of the data (black or white).It uses the <code>GPCandidateProgram</code> object with the best fitness (closest to 0). That program is given the instance attributes and evaluates a solution. The output is an integer that represents the class.</p>
</div>
<div class="paragraph">
<p>As the <code>GPWrapper</code> extends from the epochx&#8217;s <code>GPModel</code>, it also implements <code>getfitness</code> method. This method is applied to each member of the population (<strong>candidate program</strong>). Each candidate produces an output when given the input data points from the training set. If the output of the program matches the class (predicts it), a score variable is incremented. The best candidate program should have a score which should be as close to the size of the training set as possible.</p>
</div>
<div class="paragraph">
<p><code>printClassifier</code> simply finds the fittest program from the candidate pool and prints its representation, which is just a string of nested functions.</p>
</div>
<div class="paragraph">
<p>Similar to the <code>NeuralClassifier</code>, this class also contains <code>setconfig</code> function, which allows for environmental variables to be set and used to tune different parameters.
Finally, the classifier also implements visualise, which draws a representation of the training and test data to the screen using <code>Jpanel</code> in a class called <code>Picasso</code>.</p>
</div>
</div>
<div class="sect2">
<h3 id="_tuning_for_the_provided_dataset">Tuning for the provided dataset</h3>
<div class="paragraph">
<p>For the tuning, I exposed a variety of parameters that are used when creating and training the classifier. The most important tunable parameter is the population size, which represents the number of generated random program candidates. A large population range between 600 - 1200 members provided enough diversity to generate the most efficient classifiers and below 600, the accuracy relied mainly on the random seed value and luck, making the predictions unreliable.</p>
</div>
<div class="paragraph">
<p>I also decided to experiment with the generation size. When a large generation set is configured, at some point the population diversity evens out and the fittest individual does not change much. A value between 20-70 generations is the most appropriate, as it gives the programs enough time to evolve and mutate, but keeps the running time short.</p>
</div>
<div class="paragraph">
<p>Another important factor in the efficiency was selecting the syntax functions when creating the program trees. They had very significant impact on the evaluation time and efficiency.The performance of each function varied, as some were very beneficial, some had not much impact and others had a negative effect . The implementation does not include flags for tuning which type of function to use, but rather includes a selection of the the most effective ones. The highest result I was able to achieve is using <code>SignumFunction</code> as well as the trigonometry functions. I included division, subtraction and addition, as they helped with the program&#8217;s diversity.</p>
</div>
<div class="paragraph">
<p>Experimenting with number of selected elite members, crossover, mutation and reproduction probability did not provide a significant difference during my experiments.</p>
</div>
</div>
<div class="sect2">
<h3 id="_performance_report">Performance report</h3>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 1. GP algorithm with different population size</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Runtime</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Population size</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.506</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">48.421052631578945</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">10</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">7.528</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">86.31578947368422</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">40</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">10.396</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">80</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">30.763</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.52631578947368</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">200</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">53.695</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">86.31578947368422</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">500</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">163.121</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.52631578947368</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1200</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">232.42</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">92.63157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1600</p></td>
</tr>
</tbody>
</table>
<div class="imageblock">
<div class="content">
<img src="/media/gpimages/gp_population.png" alt="gp population">
</div>
</div>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 2. Table showing runs with different generations (stopping criteria)</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Generation number</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.087</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">48.91304347826087</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.267</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">54.736842105263165</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">4</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">2.045</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">75.26315789473685</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">8</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">3.582</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">86.8421052631579</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">18</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">12.429</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">91.05263157894737</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">20</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">10.704</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">87.89473684210526</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">24</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">17.317</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.52631578947368</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">28</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">16.921</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">84.73684210526315</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">30</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">14.252</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">93.15789473684211</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">40</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">25.816</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.0</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">60</p></td>
</tr>
</tbody>
</table>
<div class="imageblock">
<div class="content">
<img src="/media/gpimages/gp_generations.png" alt="gp generations">
</div>
</div>
<div class="paragraph">
<p>I also experimented with different crossover probability, number of elite chromosomes and mutation but they did not improve or lower the efficiency.  The difference I noticed is the runtime, as these parameters allow the GP to perform additional operations pore often. I have included a table with my findings for completeness.</p>
</div>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 3. Table of different size of the elite population</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">Time</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">Efficiency %</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">Elite population count</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">22.11</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">92.63157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">38.558</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">93.15789473684211</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">4</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">42.268</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.0</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">12</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">34.73</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.89473684210527</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">18</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">43.304</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.94736842105263</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">24</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">35.337</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.3157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">30</p></td>
</tr>
</tbody>
</table>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 4. Table of different crossover probability</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Crossover probability</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">77.397</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">90.0</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">87.546</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">94.21052631578948</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.3</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">82.201</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">87.36842105263159</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.4</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">58.289</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">93.15789473684211</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.8</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">62.03</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">94.21052631578948</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.0</p></td>
</tr>
</tbody>
</table>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 5. Mutation probability</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Mutation probability</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.015</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">85.78947368421052</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">94.777</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">89.47368421052632</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.2</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">79.374</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.94736842105263</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.4</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">105.695</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">93.6842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.6</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">62.391</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.8</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">71.862</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">91.57894736842105</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.0</p></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_neural_network">Neural Network</h2>
<div class="sectionbody">
<div class="sect2">
<h3 id="_revised_justification_2">Revised Justification</h3>
<div class="imageblock">
<div class="content">
<img src="/media/neuralimages/network.jpg" alt="Taken from https://www.codeproject.com/KB/dotnet/predictor/network.jpg">
</div>
</div>
<div class="paragraph">
<p>As mentioned in the coursework proposal, I chose Neural network, as the method for classification for several reasons:
It is suitable for classifying multiple 'features' as neural networks have been widely used for speech recognition, facial recognition and malignant cancer detection (Álvarez L. et al. 2009). The Universal approximation theorem also states that a neural network has the ability to compute every function. Yoshua Bengio and Yann LeCun also mention in their paper that neural networks do not have limitations in the efficiency of the representation of certain types of functions as compared to other approaches (Bengio Y., LeCun Y. 2007).</p>
</div>
<div class="paragraph">
<p>I also wanted to use a neural network, as it is a very exciting and hot topic in computing and wanted to experiment with the different activation functions and parameters.</p>
</div>
</div>
<div class="sect2">
<h3 id="_implementation_description">Implementation description</h3>
<div class="paragraph">
<p>Implementing the solution was a multi-part process. During my research, I found it suitable to use Neuroph java framework for the supervised neural network. I then outlined key features and functions that need to be implemented, tuned and integrated. The following is a detailed description of them.</p>
</div>
<div class="paragraph">
<p>Firstly, I created a special package called Neural, which contains the main class <code>Control.java</code> of the application and the <code>NeuralClassifier.java</code> class witch is a wrapper for Neuroph. For the code of <code>Control.java</code>, I used most of the sample code provided (time keeping, printing training and test data, etc.) with some minor modifications. I also replaced the Wrapper classifier with the neural implementation file <code>NeuralClassifier.java</code>. The new main class was also modified  to allow for stats dumps to csv file used to generate statistics for the report.</p>
</div>
<div class="paragraph">
<p>My <code>NeuralClassifier.java</code> extends from the <code>Classifier</code> class and thus implements <code>classifyInstance</code> and <code>printClassifier</code>. Its purpose is to be a middle man between the given framework and Neuroph. Because Neuroph uses its own data representation for the training and testing sets, an auxiliary function is provided as part of the implementation called <code>instanceSetToDataSet</code> which parses the InstanceSet and converts it to DataSet used by Neuroph.</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">NeuralClassifier.java function instanceSetToDataSet</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">public DataSet instanceSetToDataSet(InstanceSet trainingData){
        int dataRows = Attributes.getNumAttributes();
        DataSet td = new DataSet(dataRows, 1);
        ...
            // Data normalisation code skipped
            // Data scaling code skipped
            td.addRow(new DataSetRow(inputs, new double[]{instance.getClassValue()}));
        }
        ...
    }</code></pre>
</div>
</div>
<div class="paragraph">
<p>Here, the TrainingSet is converted to Data set with dynamic rows. This function is used in the constructor to bootstrap the <code>MultiLayerPerceptron</code>.</p>
</div>
<div class="paragraph">
<p>Constructing the actual class is done in the following way:</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">NeuralClassifier.java function constructor</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">NeuralClassifier(InstanceSet trainingSet){
    ...
    this.initConfig();
    DataSet trainingData = this.instanceSetToDataSet(trainingSet);
    this.mlp = new MultiLayerPerceptron(ACTIVATION_FUNCTION,
              Attributes.getNumAttributes(), HIDDENNODES, 1);
    BackPropagation b = (BackPropagation) mlp.getLearningRule();
    b.setMaxIterations(ITERATIONS);
    b.setMaxError(MAXERROR);
    b.setLearningRate(LEARNINGRATE);
    ...
    this.mlp.learn(trainingData);
}</code></pre>
</div>
</div>
<div class="paragraph">
<p>As mentioned in the proposal, I am using Multilayer perceptron with back-propagation, the above function creates and configures the neural network instance.
As described in the lecture notes, the <code>MultilayerPerceptron</code> uses an activation function which is one of the parameters for tuning, I have set the <code>Sigmoid Transfer function</code> as the default as the highest results are often achieved using it, but others are explored as part of the performance report. For the input layer, I use as many neurons as data attributes in the training set, allowing for a generic solution when applying different datasets.</p>
</div>
<div class="paragraph">
<p>Neuroph has a construct that allows for the tuning of extra parameters, like the number of iterations, max errors and learning rate, they are also configured and demonstrated in the performance section.
The given <code>Attributes</code>, <code>InstanceSet</code> and <code>Instance</code> classes were used throughout, as they provided helpful methods give the necessary information to make the solution generic.
When going though the source code, I also noticed that some examples were scaling and normalising the data, so I decided to include these features into the implementation. I used <code>DecimalScaleNormalizer.java</code> function <code>normalizeScale</code> example from the source directory of neuroph to optionally scale down each data point by a factor of 10 based on a flag. This function and the flag <code>normalise</code> in <code>instanceSetToDataSet</code> function are extra tunable parameters that I experimented with but found to cause harm to both the performance and the efficiency.</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">NeuralClassifier.java function classifyInstance</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">public int classifyInstance(Instance ins) {
    // provide the classifier with the inputs
    int numattrs = Attributes.getNumAttributes();
    double[] attributes = new double[numattrs];
    for (int i = 0; i &lt; numattrs; i++) {
        attributes[i] = ins.getRealAttribute(i);
    }
    this.mlp.setInput(attributes);

    // calculate neural network output
    this.mlp.calculate();
    double[] result = this.mlp.getOutput();
    int prediction = (int) Math.round(result[0]);
    if(prediction &gt; Attributes.getNumAttributes() || prediction &lt; 0){
        return -1;
    }
    return prediction;
}</code></pre>
</div>
</div>
<div class="paragraph">
<p><code>classifyInstance</code> function is used to return a prediction after the network has gone through the learning process. In this case, the <code>MultiLayerPerceptron</code> is given the instance data , after which the probability for each class is computed and returned. The prediction is 0 for black, 1 for white and -1 if it goes outside the domain range, or more generally, between 0 to n-1 where n is the class range.</p>
</div>
<div id="app-listing" class="listingblock">
<div class="title">NeuralClassifier.java function printClassifier</div>
<div class="content">
<pre class="highlight"><code class="language-java" data-lang="java">public void printClassifier() {
    for (Double weight : mlp.getWeights()) {
        System.out.print("Output weights: " + weight);
    }
    System.out.println();
}</code></pre>
</div>
</div>
<div class="paragraph">
<p>For printing the final classifier, I grab the weight of each node in the neural network and print it out.</p>
</div>
<div class="paragraph">
<p>Finally, I created a helper function called <code>initConfig()</code> to read environment variables that allow for dynamic tuning and shell execution of the solution for generating statistics.
I have included the shell scripts used for generating the performance data under "gp_shell" for the genetic programming algorithm and "neural_shell" for the neural network algorithm. They have been developed and tested under Ubuntu 16.04 and work by using environmental variables. When running the program, it will create a report file in the current directory with the performance, duration and the tuned parameters.</p>
</div>
<div class="paragraph">
<p>Finally, the classifier also implements visualise, which draws a representation of the training and test data to the screen using <code>Jpanel</code> in a class called <code>Picasso</code>.</p>
</div>
</div>
<div class="sect2">
<h3 id="_description_of_adjustment_and_tuning">Description of adjustment and tuning</h3>
<div class="paragraph">
<p>A neural network allows for a variety of parameter tweaking and different optimisations.
Reading up on different approaches for training a neural network, The report (Moriera, M 1995) describes the purpose of a learning rate. The paper suggests to use a learning rate that is sufficiently large to allow for the learning process but small enough to guarantee effectiveness. For that purpose, I used the learning rule function <code>setLearningRate(value)</code> and found out that a very small value in the range of <code>0.01-0.1</code> usually yields the best results. I experimented with more than one hidden layers, but often the result was identical or slightly worse but it increased the learning time, sometimes by a factor of two. Hence I decided to ignore the tuning of multiple layers, and instead allow for the tuning of different hidden nodes in the single layer. Just one layer is used, because the data to classify is not complex enough to benefit from it (not many features). Tuning the learning rate had a significant impact on the accuracy and I found that a lower learning late had a very positive impact on the correctness of the classifier for a very small performance cost.</p>
</div>
<div class="paragraph">
<p>Neuroph also provides couple of activation functions as part of the <code>MultilayerPerceptron</code> package. Experimenting with them, I thought initially that the gaussian function will yield the best result, but by far the most efficient function was <code>sigmoid</code>, which consistently achieves results above 90% accuracy. To contrast that with the <strong>tanH</strong> function, it has an extremely negative effect on the accuracy, making the prediction absolutely wrong. Another function that performed very poorly is the <strong>linear</strong> function, which yields 50% accuracy, making the classifier more similar to a coin toss.</p>
</div>
<div class="paragraph">
<p>An article on standardising data for neural networks (McCaffrey J. 2014) an argument for normalisation of the data is made. I have allowed for a normalisation flag in my implementation, but enabling it has a negative effect due to the data being evenly distributed and relatively short. As mentioned above, data can also be scaled, but again, this also has a negative effect on the accuracy.</p>
</div>
</div>
<div class="sect2">
<h3 id="_performance_report_2">Performance report</h3>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 6. Efficiency with different iterations</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top"><strong>Time in seconds</strong></th>
<th class="tableblock halign-left valign-top"><strong>Efficiency in %</strong></th>
<th class="tableblock halign-left valign-top">Number of iterations</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.189</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">85.26315789473684</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.489</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">86.8421052631579</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">20</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">0.838</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">87.36842105263159</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">40</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.121</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">87.89473684210526</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">60</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.371</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">80</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">1.642</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">88.94736842105263</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">100</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">10.2</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.3157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">748</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">13.524</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.3157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">997</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">26.391</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.36842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1993</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">28.076</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.36842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">2242</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">21.338</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.84210526315789</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">2989</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">32.731</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.84210526315789</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">3238</p></td>
</tr>
</tbody>
</table>
<div class="paragraph">
<p>The table above shows improvement in performance with the increase of iterations. In my case, it peaked at about 1500-2000 iterations, at which point it did not have a significant impact on the efficiency but it impacted the running time.</p>
</div>
<div class="literalblock">
<div class="content">
<pre>image::/media/neuralimages/iterations.png[]</pre>
</div>
</div>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 7. Impact on different hidden nodes</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top"><strong>Time</strong></th>
<th class="tableblock halign-left valign-top"><strong>Accuracy in %</strong></th>
<th class="tableblock halign-left valign-top"><strong>Hidden nodes</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">6.379</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">82.10526315789474</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">1</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">9.108</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">84.21052631578947</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">3</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">12.434</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">91.05263157894737</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">6</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">12.125</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">94.21052631578948</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">10</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">14.309</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">98.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">17</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">16.069</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.36842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">23</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.644</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">98.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">24</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">17.264</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">95.78947368421052</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">29</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">17.871</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.89473684210527</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">33</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">18.304</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.36842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">36</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">20.96</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">97.36842105263158</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">40</p></td>
</tr>
</tbody>
</table>
<div class="imageblock">
<div class="content">
<img src="/media/neuralimages/hidden_nodes.png" alt="hidden nodes">
</div>
</div>
<div class="paragraph">
<p>In this case, increasing the amount of hidden nodes had a significant impact on the accuracy, with it peaking at about 17-24 nodes. I found that using 18 hidden nodes fairly reliably produced around 98% accuracy, thus chose it as the base for some runs.</p>
</div>
<div class="paragraph">
<p>To keep this report short, I will include a graph of learning rate and max error results without including the tables, but the data can be found and viewed under neuralstats.csv</p>
</div>
<div class="imageblock">
<div class="content">
<img src="/media/neuralimages/learningrate.png" alt="learningrate">
</div>
</div>
<div class="imageblock">
<div class="content">
<img src="/media/neuralimages/maxewrrorrate.png" alt="maxewrrorrate">
</div>
</div>
<div class="paragraph">
<p>I observed that learning rate and max error rate were the most efficient at around 1% and increasing them had mostly negative effect on the effectiveness.</p>
</div>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 8. Normalisation vs. no normalisation</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Normalised</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.487,</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">82.63157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">yes</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.009</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">98.42105263157895</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">No</p></td>
</tr>
</tbody>
</table>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 9. Down scaling (factor of 10) vs. no down scaling</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Scaled down</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.652,</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">74.21052631578947</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">Yes</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">15.705,</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">96.3157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">No</p></td>
</tr>
</tbody>
</table>
<div class="paragraph">
<p>As mentioned above, experimenting with scaling or normalising the data did not yield a positive effect, on the contrary, it reduced the classifier&#8217;s ability to make accurate predictions.</p>
</div>
<table class="tableblock frame-all grid-all spread">
<caption class="title">Table 10. Different activation functions</caption>
<colgroup>
<col style="width: 33.3333%;">
<col style="width: 33.3333%;">
<col style="width: 33.3334%;">
</colgroup>
<thead>
<tr>
<th class="tableblock halign-left valign-top">Time</th>
<th class="tableblock halign-left valign-top">Efficiency in %</th>
<th class="tableblock halign-left valign-top">Activation function</th>
</tr>
</thead>
<tbody>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">16.638</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">95.78947368421052</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">SIGMOID</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">16.37</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">92.63157894736842</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">GAUSSIAN</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">14.283</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">50.0</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">LINEAR</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">13.596</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">17.20430107526882</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">TANH</p></td>
</tr>
<tr>
<td class="tableblock halign-left valign-top"><p class="tableblock">14.101,</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">50.0</p></td>
<td class="tableblock halign-left valign-top"><p class="tableblock">TRAPEZOID</p></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_comparison_between_methods">Comparison between methods</h2>
<div class="sectionbody">
<div class="paragraph">
<p>The difference between genetic programming and neural networks (MLP) was very noticeable. The neural network produced a more generic solution, as less knowledge was provided to it. To contrast that with the GP, many variables had to be tuned specifically to achieve the optimal result using syntax functions that are relevant to the solution. Neural networks are also faster and more efficient, outperforming the GP implementation. The implementation of the neural network is also a bit harder to reason with and the library hides most of the complexity away from the developer.</p>
</div>
<div class="paragraph">
<p>On the other hand, the Genetic Programming algorithm seemed more simple and intuitive, the tunable parameters had a direct impact on the result and the classification representation is simple. The program is also less generic as it required special tuning to achieve good results. It also does not provide consistent accuracy, where as the Neural Network had much smaller margin of error. The classifier is also easier to visualise, as it is just a mathematical function.</p>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_general_note">General note</h2>
<div class="sectionbody">
<div class="paragraph">
<p>The sourcecode folder contains gp_shell and neural_shell bash scripts that will work only on linux.</p>
</div>
<div class="paragraph">
<p>To manually run the java executable, use the following commands<br>
<code>java -cp CSC3423.jar Biocomputing.Neural.Control dataset/Training.arff dataset/Test.arff</code><br>
<code>java -cp CSC3423.jar Biocomputing.GP.GPControl dataset/Training.arff dataset/Test.arff</code><br>
Where <code>CSC3423.jar</code> is the executable jar file in the out folder and the arff files are the Training and Testing data sets.<br>
The Neural network accepts the following environmental variables: <code>ITERATIONS</code>, <code>GENERATIONS</code>,<code>ACTIVATION_FUNCTION</code>, <code>HIDDENNODES</code>,<code>MAXERROR</code>,<code>LEARNINGRATE</code>,<code>NORMALISE</code>,<code>SCALE</code>.<br>
GPClassifier environmental varialbes: <code>POPULATION_SIZE</code>, <code>GENERATIONS</code>, <code>ELITES</code>, <code>CROSSOVER_PROB</code>, <code>MUTATION_PROB</code>, <code>REPRODUCTION_PROB</code> and <code>TOURNAMENT_SIZE</code>.<br>
In windows, one can use the command <code>set HIDDENNODES=5</code> followed by the java run command to set these values.<br>
Performance stats ran on <code>Intel Core i3 (4170) 3.7GHz Processor</code>.</p>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_references">References</h2>
<div class="sectionbody">
<div class="olist arabic">
<ol class="arabic">
<li>
<p>Moreira, M. (1995). Neural Networks with Adaptive Learning Rate and Momentum Terms. Available at <a href="https://infoscience.epfl.ch/record/82307/files/95-04.pdf" class="bare">https://infoscience.epfl.ch/record/82307/files/95-04.pdf</a>. Accessed on 12.12.2016</p>
</li>
<li>
<p>Kun-Hong L. et al. (2008). A genetic programming-based approach to the classification of multiclass microarray datasets. Available at <a href="http://bioinformatics.oxfordjournals.org/content/25/3/331.full" class="bare">http://bioinformatics.oxfordjournals.org/content/25/3/331.full</a>. Accessed on 14.12.2016</p>
</li>
<li>
<p>McCaffrey J. (2014). How To Standardize Data for Neural Networks. Available at <a href="https://visualstudiomagazine.com/articles/2014/01/01/how-to-standardize-data-for-neural-networks.aspx" class="bare">https://visualstudiomagazine.com/articles/2014/01/01/how-to-standardize-data-for-neural-networks.aspx</a>. Accessed on 14.12.2016.</p>
</li>
<li>
<p>Jeroen Eggermont et al (2004). Genetic Programming for Data Classification:
Partitioning the Search Space. Available at <a href="http://liacs.leidenuniv.nl/~kosterswa/SAC2003final.pdf" class="bare">http://liacs.leidenuniv.nl/~kosterswa/SAC2003final.pdf</a>. Accessed on 15.12.2016</p>
</li>
<li>
<p>Álvarez L. et al. (2009). Artificial neural networks applied to cancer detection in a breast screening programme. Available at <a href="http://ac.els-cdn.com/S0895717710001378/1-s2.0-S0895717710001378-main.pdf?_tid=c4a6e3c0-c2b3-11e6-9ddd-00000aab0f6b&amp;acdnat=1481798983_5428dbaa26e2d27c669d7906a5c1a77a" class="bare">http://ac.els-cdn.com/S0895717710001378/1-s2.0-S0895717710001378-main.pdf?_tid=c4a6e3c0-c2b3-11e6-9ddd-00000aab0f6b&amp;acdnat=1481798983_5428dbaa26e2d27c669d7906a5c1a77a</a>. Accessed on 15.12.2016</p>
</li>
<li>
<p>Bengio Y., LeCun Y. (2007) Scaling Learning Algorithms towards AI. Available at <a href="http://yann.lecun.com/exdb/publis/pdf/bengio-lecun-07.pdf" class="bare">http://yann.lecun.com/exdb/publis/pdf/bengio-lecun-07.pdf</a> (Accessed: 16 Nov 2016).</p>
</li>
</ol>
</div>
</div>
</div>
<div class="sect1">
<h2 id="_credits">Credits</h2>
<div class="sectionbody">
<div class="olist arabic">
<ol class="arabic">
<li>
<p>Genetic programming tree image taken from <a href="http://www.ra.cs.uni-tuebingen.de/software/JCell/images/docbook/gp.png" class="bare">http://www.ra.cs.uni-tuebingen.de/software/JCell/images/docbook/gp.png</a></p>
</li>
<li>
<p>Multilayer perceptron with back-propagation image taken from <a href="https://www.codeproject.com/KB/dotnet/predictor/network.jpg" class="bare">https://www.codeproject.com/KB/dotnet/predictor/network.jpg</a></p>
</li>
</ol>
</div>
</div>
</div>
</div>
HEREDOC
    a.tags = 'Neural networks, Genetic Programming, MLP, Machine Learning, epochx, classification, sigmoidal'
    a.save

    # now to generate artworks
    for i in %w(cr.jpg hackne_logo.jpg hackne_poster.jpg hackne_print.jpg lloyds_bank.jpg lux.png neven.jpg spendwell_poster.jpg spenwell_app.jpg stage_tuts.jpg)
      
      File.open("#{Rails.public_path}/media/images/creative/#{i}") do |f|
        Artwork.create(
          image: f
        )
      end
    end

    # generate cv content

    data = [
      {
        :type => 'about',
        :title => '',
        :body => <<-HERE,
        <p>
My name is Plamen Kolev and I am a Newcastle based
developer specializing in web application development,
system automation and web application deployment. I
enjoy playing with emerging technologies to build better
software.
        </p>
        <p>
I have worked with Perl, Bash, python for web
development, PHP and ruby. I am a strong advocate for
Linux and love working with open-source software.
        </p>
HERE
        :date => ''

      },
      # ======= EXPERIENCE
      {
        :type => 'experience',
        :title => 'Software Engineer Intern,<br/> Intel Corporation',
        :date => 'August 2015 - September 2016',
        :body => <<-HERE,
          Worked on high-performing, cyber security projects.
Created automated tests using bash, Perl and in-house
tools. Developed scripts to automate product integration
and deployment in a large, multi-national team.
HERE
      },
      {
        :type => 'experience',
        :title => 'Interviewer, Populus Data Solutions',
        :date => 'April 2014 - June 2015',
        :body => <<-HERE,
          Conducted national studies across Britain on socio-political issues
HERE
      },
      {
        :type => 'experience',
        :title => 'Graphic Designer, Ivesto Company',
        :date =>  'September 2012 - June 2013',
        :body => <<-HERE
          Worked full time as a website manager and designer where I had the opportunity to improve the user experience and maintain the two websites of the company.
HERE
      },
      # ===== EDUCATION
      {
        :type => 'education',
        :title => 'BSc. Computer Science,<br/> Newcastle University',
        :date => 'September 2013 - June 2017',
        :body => <<-HERE,
Studied object-oriented programing - design &
development. relational database technologies.
Computer Architecture: Parallel Computer Architectures.
Software Engineering - principles and life cycle,
scalability and maintenance.
Team projects, working as part of a group.
Distributed systems and modelling concurrent systems.
HERE

      },
      # =============== PROJECTS
      {
        :type => 'project',
        :title => "Web Platform for Digital Deployment of Virtual Servers",
        :date => "November 2016 - Present",
        :body => <<-HERE
Currently creating a platform for deployment, management
and monitoring of virtual servers as part of final year
dissertation.
Technologies used: Puppet, BASH shell, Virtualbox,
Vagrant, Ruby, Ruby On Rails.
HERE
      },
      {
        :type => 'project',
        :title => 'Neven Body care',
        :date => '5 August - 28 August 2016',
        :body => <<-HERE,
        Created a PHP website for the Neven brand, the website is deployed <a href="https://nevv.herokuapp.com/">here</a>.
        It features internationalisation and stripe payment integration.
HERE
      },
      {
        :type => 'project',
        :title => 'Secure Coding Presentation',
        :date => "5 May 2016",
        :body => <<-HERE,
Gave a presentation in Lester College about different ways
code can be exploited by a malicious user and ways to
mitigate and avoid such cases.
HERE
      },
      {
        :type => 'project',
        :title => 'Lloyds Banking',
        :date => '31 October 2014',
        :body => <<-HERE,
Developed and designed a website with restful API that
hooks to an Android application for the British bank
Lloyds. The product was produced as part of a team
project.
HERE
      },
      {
        :type => 'project',
        :title => "HackNE Hackathon",
        :date => '31 October 2014',
        :body => <<-HERE
Co-organized a hackathon in the North East, United Kingdom backed by Major League Hacking EU.<br/> Created the website for the event, PR and print design materials.
HERE
      },
      {
        :type => 'project',
        :title => 'PAConsulting',
        :date => '12 February 2014',
        :body => <<-HERE,
          Developed an environmental friendly hardware &amp; software solution with the Raspberry Pi that involves predictive light automation and control.
HERE
      }

    ]

    
    for i in data do
      Skill.create(
        skill_type:   i[:type],
        title:  i[:title],
        date:   i[:date],
        body:   i[:body]
      )
    end
    
    # Now generate the static website
    all_articles = Article.all
    ## index
    index_page = PagesController.render(
      template: 'pages/index',
      assigns: { articles: all_articles }
    )

    articles_all = PagesController.render(
      template: 'articles/index',
      assigns: { articles: all_articles }
    )

    creative = PagesController.render(
      template: 'creatives/index',
      assigns: { artworks: Artwork.all }
    )


    # grab all bio relevant stuff
    @skills = Skill.all
    
    @about
    @work_experience = []
    @education = []
    @projects = []

    @skills.each do | skill |
      if skill.skill_type == 'about'
        @about = skill
      elsif skill.skill_type == 'experience'
        @work_experience << skill
      elsif skill.skill_type == 'education'
        @education << skill
      elsif skill.skill_type == 'project'
        @projects << skill
      end

    end

    biography = PagesController.render(
      template: 'biography/index',
      assigns: { 
        about: @about,
        work_experience: @work_experience,
        education: @education,
        projects: @projects
      }
    )

    four_oh_four = PagesController.render(
        template: 'pages/error_404'
    )

    keybase = PagesController.render(
        text: "hKRib2R5hqhkZXRhY2hlZMOpaGFzaF90eXBlCqNrZXnEIwEgW516ZGqInOKwnCCB/dPKp1aAR16qXYAujMhztq47F7MKp3BheWxvYWTFAvN7ImJvZHkiOnsia2V5Ijp7ImVsZGVzdF9raWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwiaG9zdCI6ImtleWJhc2UuaW8iLCJraWQiOiIwMTIwNWI5ZDdhNjQ2YTg4OWNlMmIwOWMyMDgxZmRkM2NhYTc1NjgwNDc1ZWFhNWQ4MDJlOGNjODczYjZhZTNiMTdiMzBhIiwidWlkIjoiYjI3ZDliY2VjNmQyOTQ2NTcxYTI4MDUyZTVlMWJkMTkiLCJ1c2VybmFtZSI6InBsYW1lbmtvbGV2In0sInNlcnZpY2UiOnsiaG9zdG5hbWUiOiJrb2xldi5pbyIsInByb3RvY29sIjoiaHR0cDoifSwidHlwZSI6IndlYl9zZXJ2aWNlX2JpbmRpbmciLCJ2ZXJzaW9uIjoxfSwiY2xpZW50Ijp7Im5hbWUiOiJrZXliYXNlLmlvIGdvIGNsaWVudCIsInZlcnNpb24iOiIxLjAuMTgifSwiY3RpbWUiOjE0ODc3MDA2MTEsImV4cGlyZV9pbiI6NTA0NTc2MDAwLCJtZXJrbGVfcm9vdCI6eyJjdGltZSI6MTQ4NzcwMDYwMiwiaGFzaCI6ImMwYzJiNzhhMTBlOWM2ZTkzYTcyYWIzYWQ1M2ZmZWU2MzNkOTU3ODdmYzU3YjY5NDdjMzYzNTQxYzc4ZjcyNWQ2YWYxZTE1MDc4ZjdjN2FkMWY3ZWQwYTViOTJiZDY4MzA3YTdiYWZjOTM0NzNiZDVlZDZkMjdmZWNlYWI5MTU1Iiwic2Vxbm8iOjkxMTI0OX0sInByZXYiOiJkNzVhNDczZDUxOTBjZmM0ZDQyMmJhY2M5ODg5ZjFmNzk2ZDkxNThjN2JjODQwZGE1ZDk3OGY4YmQyNjg3MzgwIiwic2Vxbm8iOjE3LCJ0YWciOiJzaWduYXR1cmUifaNzaWfEQCXV2wYy8DQAToIZpBq7BRIHvx757tI30SqPwXLJKJ+PWp91+I8WY9KxQLIpN9t9LcaNFGm8FJqh75aG3ITUIAGoc2lnX3R5cGUgpGhhc2iCpHR5cGUIpXZhbHVlxCA8LYZBNOM5DjSHiQSvZ0VddSOO+58J7kZSyFwMLwAUeqN0YWfNAgKndmVyc2lvbgE="
    )

    cname = PagesController.render(
        text: "kolev.io"
    )

    robots = PagesController.render(
        text: <<-HERE
User-agent: *
Disallow:
HERE
    )

    Rake::Task['assets:precompile'].invoke

    # before file operations, create dependant folders
    static_dir = 'plamen-kolev.github.io'
    Dir.mkdir(static_dir) unless File.exists?(static_dir)
    Dir.mkdir("#{static_dir}/articles") unless File.exists?("#{static_dir}/articles")

    File.open("plamen-kolev.github.io/index.html", "w") { |file| file.write(index_page) }
    File.open("plamen-kolev.github.io/articles.html", "w") { |file| file.write(articles_all) }
    File.open("plamen-kolev.github.io/creative.html", "w") { |file| file.write(creative) }
    File.open("plamen-kolev.github.io/biography.html", "w") { |file| file.write(biography) }
    File.open("plamen-kolev.github.io/404.html", "w") { |file| file.write(four_oh_four) }
    # keybase verification signature
    File.open("plamen-kolev.github.io/keybase.txt", "w") { |file| file.write(keybase) }
    # CNAME from namecheap
    File.open("plamen-kolev.github.io/CNAME", "w") { |file| file.write(cname) }
    File.open("plamen-kolev.github.io/robots.txt", "w") { |file| file.write(robots) }

    # now to write each article
    all_articles.each do |article|
      html_article = PagesController.render(
        template: 'articles/show',
        assigns: { article: article }
      )
      File.open("plamen-kolev.github.io/articles/#{article.slug}.html", "w") { |file| file.write(html_article) }
    end


    FileUtils.copy_entry "#{Rails.public_path}/assets", "#{Rails.root}/plamen-kolev.github.io/assets/"
    FileUtils.copy_entry "#{Rails.public_path}/media", "#{Rails.root}/plamen-kolev.github.io/media"
  end



end
